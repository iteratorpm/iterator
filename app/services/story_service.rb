class StoryService
  def initialize(story, current_user = nil)
    @story = story
    @current_user = current_user
    @project = story.project
  end

  # Create a story with optional recalculation
  def self.create(project, story, recalculate: nil)

    return [story, false] unless story.save

    if recalculate.nil?
      recalculate = project.auto_iteration_planning
    end

    # Only recalculate if requested AND the story would trigger a recalculation
    if recalculate && (story.backlog? || story.iteration_recalculation_needed?)
      project.recalculate_iterations
    end

    [story, true]
  end

  # Update a story with optional recalculation
  def update(attributes, recalculate: nil)

    if recalculate.nil?
      recalculate = @project.auto_iteration_planning
    end

    # Store whether recalculation would be needed before updating
    recalculation_needed = @story.iteration_recalculation_needed?

    # Use existing update_with_user method if it handles user tracking
    success = if @current_user
                @story.update_with_user(attributes, @current_user)
              else
                @story.update(attributes)
              end

    # Only recalculate if requested AND the story would trigger a recalculation
    if success && recalculate && (recalculation_needed || @story.iteration_recalculation_needed?)
      @project.recalculate_iterations
    end

    success
  end

  # Destroy a story with optional recalculation
  def destroy(recalculate: nil)
    if recalculate.nil?
      recalculate = @project.auto_iteration_planning
    end

    # Remember the project before destroying
    project = @story.project

    success = @story.destroy

    # Only recalculate if requested and if story was successfully destroyed
    if success && recalculate
      @project.recalculate_iterations
    end

    success
  end
end
