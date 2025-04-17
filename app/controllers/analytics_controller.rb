class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :calculate_report_data, only: :overview

  def overview
  end

  def velocity
    # Velocity report specific logic
  end

  def composition
    # Composition report specific logic
  end

  def cycle_time
    # Cycle time report specific logic
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize! :read, @project
  end

  def calculate_report_data
    # Calculate velocity data
    @velocity_data = {
      current_points: @project.current_iteration_points,
      average_velocity: @project.average_velocity(5),
      iterations: @project.last_5_iterations.map do |iter|
        {
          date: iter.start_date.strftime("%b %d"),
          points: iter.points_accepted,
          velocity: iter.velocity
        }
      end
    }

    # Calculate stories data
    @stories_data = {
      total: @project.stories.accepted.count,
      by_type: {
        "Feature" => @project.stories.features.accepted.count,
        "Bug" => @project.stories.bugs.accepted.count,
        "Chore" => @project.stories.chores.accepted.count
      },
      iterations: @project.last_5_iterations.map do |iter|
        {
          date: iter.start_date.strftime("%b %d"),
          features: iter.stories.features.accepted.count,
          bugs: iter.stories.bugs.accepted.count,
          chores: iter.stories.chores.accepted.count
        }
      end
    }

    # Calculate cycle time data
    @cycle_time_data = {
      current: @project.current_iteration_cycle_time,
      average: @project.average_cycle_time(5),
      iterations: @project.last_5_iterations.map do |iter|
        {
          date: iter.start_date.strftime("%b %d"),
          cycle_time: iter.average_cycle_time
        }
      end
    }

    # Calculate rejection rate data
    @rejection_data = {
      current: @project.current_iteration_rejection_rate,
      average: @project.average_rejection_rate(5),
      iterations: @project.last_5_iterations.map do |iter|
        {
          date: iter.start_date.strftime("%b %d"),
          rejection_rate: iter.rejection_rate
        }
      end
    }

    @burnup_data = {
      accepted: @project.last_5_iterations.each_with_object({}) do |iter, hash|
        hash[iter.start_date.strftime("%b %d")] = iter.points_accepted
      end,
      scope: @project.last_5_iterations.each_with_object({}) do |iter, hash|
        hash[iter.start_date.strftime("%b %d")] = iter.scope_points
      end
    }
  end
end
