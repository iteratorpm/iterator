class StoryService
  include Rails.application.routes.url_helpers

  def initialize(story, current_user = nil)
    @story = story
    @current_user = current_user
    @project = story.project
  end

  # Create a story with optional recalculation and broadcasting
  def self.create(project, story_attributes, current_user: nil, recalculate: nil, broadcast: true, existing_story: nil)
    story = existing_story || project.stories.build(story_attributes)
    service = new(story, current_user)

    return [story, false] unless story.save

    if recalculate.nil?
      recalculate = project.auto_iteration_planning
    end

    # Handle recalculation
    recalculation_happened = false
    if recalculate && (story.backlog? || story.iteration_recalculation_needed?)
      project.recalculate_iterations
      story.reload # Reload to get updated iteration assignment
      recalculation_happened = true
    end

    # Handle broadcasting
    if broadcast
      service.broadcast_story_created(recalculation_happened)
    end

    [story, true]
  end

  # Update a story with optional recalculation and broadcasting
  def update(attributes, recalculate: nil, broadcast: true)
    if recalculate.nil?
      recalculate = @project.auto_iteration_planning
    end

    # Capture state before update for broadcasting
    previous_attributes = @story.attributes.dup
    previous_owner_ids = @story.owner_ids.dup
    recalculation_needed = @story.iteration_recalculation_needed?

    # Perform the update
    success = if @current_user
                @story.update_with_user(attributes, @current_user)
              else
                @story.update(attributes)
              end

    return false unless success

    # Handle recalculation
    changes = @story.saved_changes
    recalculation_happened = false
    if recalculate && (recalculation_needed || @story.iteration_recalculation_needed?)
      @project.recalculate_iterations
      @story.reload # Reload to get updated iteration assignment
      recalculation_happened = true
    end

    # Handle broadcasting
    if broadcast
      broadcast_story_updated(changes, previous_owner_ids, recalculation_happened)
    end

    true
  end

  # Destroy a story with optional recalculation and broadcasting
  def destroy(recalculate: nil, broadcast: true)
    if recalculate.nil?
      recalculate = @project.auto_iteration_planning
    end

    # Capture state before destruction for broadcasting
    story_columns_snapshot = capture_story_columns_for_all_users
    project = @story.project

    success = @story.destroy
    return false unless success

    # Handle recalculation
    recalculation_happened = false
    if recalculate
      project.recalculate_iterations
      recalculation_happened = true
    end

    # Handle broadcasting
    if broadcast
      broadcast_story_destroyed(story_columns_snapshot, recalculation_happened)
    end

    true
  end

  def broadcast_story_created(recalculation_happened)
    if recalculation_happened
      # If recalculation happened, broadcast all affected columns
      broadcast_full_project_update
    else
      # Otherwise, just broadcast the specific columns this story affects
      broadcast_story_columns(@story.current_columns_for_all_users)
    end
  end

  private

  def broadcast_story_columns(columns_by_user)
    # columns_by_user is a hash: { user_id => [columns], nil => [general_columns] }

    # Get all unique columns that need broadcasting
    all_columns = columns_by_user.values.flatten.uniq

    # Get all user IDs that might need my_work updates
    all_user_ids = columns_by_user.keys.compact

    broadcast_specific_columns(all_columns, all_user_ids)
  end

  def broadcast_story_updated(changes, previous_owner_ids, recalculation_happened)
    if recalculation_happened
      # If recalculation happened, broadcast everything
      broadcast_full_project_update
    else
      # Get all affected users (current and previous owners)
      all_affected_user_ids = (@story.owner_ids + previous_owner_ids).uniq

      # Calculate which columns need updates
      affected_columns = Set.new

      all_affected_user_ids.each do |user_id|
        current_cols = @story.current_columns(user_id)
        previous_cols = @story.previous_columns_from_changes(changes, user_id)
        affected_columns.merge(current_cols + previous_cols)
      end

      # Also add general columns (non-user-specific)
      general_current = @story.current_columns(nil)
      general_previous = @story.previous_columns_from_changes(changes, nil)
      affected_columns.merge(general_current + general_previous)

      broadcast_specific_columns(affected_columns.to_a, all_affected_user_ids)
    end
  end

  def broadcast_story_destroyed(story_columns_snapshot, recalculation_happened)
    if recalculation_happened
      broadcast_full_project_update
    else
      # Broadcast updates to all columns the story was in
      all_user_ids = story_columns_snapshot.keys
      all_columns = story_columns_snapshot.values.flatten.uniq

      broadcast_specific_columns(all_columns, all_user_ids)
    end
  end

  def broadcast_full_project_update
    # When recalculation happens, we need to update all columns
    # because stories might have moved between iterations

    columns_to_update = [:icebox, :backlog, :current, :done]

    columns_to_update.each do |column|
      broadcast_column_update(column)
    end

    # Also update My Work for all project members
    @project.memberships.find_each do |user|
      broadcast_column_update(:my_work, user.id)
    end
  end

  def broadcast_specific_columns(columns, user_ids = [])
    columns.each do |column|
      if column == :my_work
        user_ids.each do |user_id|
          broadcast_column_update(:my_work, user_id)
        end
      else
        broadcast_column_update(column)
      end
    end
  end

  def capture_story_columns_for_all_users
    # Get all users who might be affected (owners + project members)
    relevant_user_ids = (@story.owner_ids + @project.membership_ids).uniq

    columns_snapshot = {}
    relevant_user_ids.each do |user_id|
      columns_snapshot[user_id] = @story.current_columns(user_id)
    end

    columns_snapshot
  end

  def broadcast_column_update(column, user_id = nil)
    case column
    when :icebox
      broadcast_update_later_to(
        [@project, "stories"],
        target: "column-icebox",
        partial: "projects/stories/column",
        locals: {
          project_id: @project.id,
          state: :unscheduled,
          column_type: :icebox
        }
      )
    when :backlog
      broadcast_update_later_to(
        [@project, "stories"],
        target: "column-backlog",
        partial: "projects/iterations/column",
        locals: {
          project_id: @project.id,
          iteration_state: :backlog,
          column_type: :backlog
        }
      )
    when :current
      broadcast_update_later_to(
        [@project, "stories"],
        target: "column-current",
        partial: "projects/iterations/column",
        locals: {
          project_id: @project.id,
          iteration_state: :current,
          column_type: :current
        }
      )
    when :done
      broadcast_update_later_to(
        [@project, "stories"],
        target: "column-done",
        partial: "projects/iterations/column",
        locals: {
          project_id: @project.id,
          iteration_state: :done,
          column_type: :done
        }
      )
    when :my_work
      broadcast_update_later_to(
        [@project, "stories", "user_#{user_id}"],
        target: "column-my-work",
        partial: "projects/stories/column",
        locals: {
          project_id: @project.id,
          user_id: user_id,
          column_type: :my_work
        }
      )
    end
  end

  def broadcast_update_later_to(stream_name, **options)
    # Use Turbo::StreamsChannel to broadcast
    Turbo::StreamsChannel.broadcast_update_later_to(
      stream_name,
      **options
    )
  end
end
