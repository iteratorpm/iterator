module IterationPlanner
  class << self
    def recalculate_all_iterations(project)
      project.transaction do
        # Step 1: Update the velocity based on historical data
        new_velocity = calculate_project_velocity(project)
        project.update(velocity: new_velocity)

        # Step 2: Ensure we have a valid current iteration
        current_iteration = find_or_create_current_iteration(project)

        # Step 3: Clear future iterations and replan
        project.iterations.backlog.destroy_all

        # Step 4: Fill current iteration with appropriate stories
        fill_current_iteration(current_iteration)

        # Step 5: Plan future iterations with remaining stories
        plan_future_iterations(project)
      end
    end

    def calculate_project_velocity(project)
      # Get completed iterations based on velocity strategy
      lookback_count = case project.velocity_strategy
                       when 'past_iters_1' then 1
                       when 'past_iters_2' then 2
                       when 'past_iters_3' then 3
                       when 'past_iters_4' then 4
                       else 2 # Default to 2 iterations
                       end

      completed_iterations = project.iterations.done.order(end_date: :desc).limit(lookback_count)

      # If no completed iterations, use initial velocity or default
      return project.initial_velocity || 10 if completed_iterations.empty?

      # Calculate average points completed, adjusted for team strength
      total_normalized_points = completed_iterations.sum do |iteration|
        iteration.points_completed / (iteration.team_strength.to_f / 100.0)
      end

      # Calculate average per week, then multiply by iteration length
      total_weeks = completed_iterations.sum(&:length_in_weeks)
      return project.initial_velocity || 10 if total_weeks.zero?

      (total_normalized_points / total_weeks * project.iteration_length).round
    end

    def find_or_create_current_iteration(project)
      Time.use_zone(project.time_zone) do
        today = Time.zone.today

        # First check if we have a current iteration
        current = project.iterations.current.first
        return current if current

        # Look for an iteration containing today
        containing_iteration = project.iterations.where("start_date <= ? AND end_date >= ?", today, today).first
        return containing_iteration if containing_iteration

        # Create a new iteration
        create_new_iteration(project, current_date: today)
      end
    end

    def create_new_iteration(project, current_date: nil)
      Time.use_zone(project.time_zone) do
        current_date ||= Time.zone.today

        # Calculate the start date based on iteration start day preference
        preferred_wday = project.iteration_start_day_before_type_cast.to_i
        days_since_start_day = (current_date.wday - preferred_wday) % 7
        start_date = current_date - days_since_start_day

        # Calculate end date based on iteration length
        end_date = start_date + (project.iteration_length.weeks - 1.day)

        # Get next iteration number
        last_number = project.iterations.maximum(:number) || 0
        new_number = last_number + 1

        # Create the iteration
        project.iterations.create!(
          start_date: start_date,
          end_date: end_date,
          number: new_number,
          state: :current,
          velocity: project.velocity
        ).tap do |iteration|
          # Make sure only one current iteration exists
          project.iterations.where.not(id: iteration.id).where(state: :current).update_all(state: :done)
        end
      end
    end

    def fill_current_iteration(iteration)
      project = iteration.project

      # Get stories that should be in this iteration (started, finished, delivered, rejected)
      current_stories = project.stories.current
      current_stories.update_all(iteration_id: iteration.id)

      # Get unstarted stories (backlog)
      backlog_stories = project.stories.unstarted.no_iteration.ranked

      # Fill iteration up to velocity
      points_remaining = iteration.velocity
      current_points = iteration.stories.estimated.sum(:estimate)
      points_remaining -= current_points

      backlog_stories.each do |story|
        break if points_remaining <= 0

        if story.estimated?
          if story.estimate <= points_remaining
            story.update!(iteration: iteration)
            points_remaining -= story.estimate
          else
            # Stop if the next story would exceed capacity
            break
          end
        else
          # Unestimated stories (estimate = -1) don't count against velocity
          story.update!(iteration: iteration)
        end
      end
    end

    def plan_future_iterations(project)
      Time.use_zone(project.time_zone) do
        # Get current iteration to start planning from
        current_iteration = project.iterations.current.first
        return unless current_iteration

        # Get remaining backlog stories that aren't assigned to an iteration
        remaining_stories = project.stories.no_iteration.unstarted.ranked
        return if remaining_stories.empty?

        # Start planning from the end of the current iteration
        next_start_date = current_iteration.end_date + 1.day
        iteration_number = current_iteration.number + 1
        velocity = project.velocity

        # Initialize the first iteration
        current_backlog_iteration = project.iterations.create!(
          start_date: next_start_date,
          end_date: next_start_date + (project.iteration_length.weeks - 1.day),
          number: iteration_number,
          state: :backlog,
          velocity: velocity
        )

        # Track points used in current iteration
        points_used = 0

        # Process stories in strict position order
        remaining_stories.each do |story|
          if story.estimated?
            # Check if this story would exceed the current iteration's velocity
            if points_used + story.estimate > velocity
              # Create a new iteration if this story can't fit
              iteration_number += 1
              next_start_date += project.iteration_length.weeks

              current_backlog_iteration = project.iterations.create!(
                start_date: next_start_date,
                end_date: next_start_date + (project.iteration_length.weeks - 1.day),
                number: iteration_number,
                state: :backlog,
                velocity: velocity
              )

              # Reset points for new iteration
              points_used = story.estimate
            else
              # Add to current points if it fits
              points_used += story.estimate
            end
          end

          # Assign story to current iteration (estimated or unestimated)
          story.update!(iteration: current_backlog_iteration)

          # Safety valve - limit to a reasonable number of iterations
          break if iteration_number > current_iteration.number + 50
        end

        # Clean up any empty iterations that might have been created
        project.iterations.backlog.includes(:stories).where(stories: { id: nil }).destroy_all
      end
    end
  end
end
