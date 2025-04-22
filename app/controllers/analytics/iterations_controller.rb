class Analytics::IterationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def show
    @current_iteration = current_iteration_data
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize! :read, @project
  end

  def current_iteration_data
    current_iteration = @project.iterations.current.first || @project.iterations.last
    past_iterations = @project.iterations.past.order(number: :desc).limit(5)

    {
      name: current_iteration.display_name,
      options: iteration_options(past_iterations, current_iteration),
      points_accepted: current_iteration_points_accepted(current_iteration),
      stories_accepted: current_iteration_stories_accepted(current_iteration),
      cycle_time: average_cycle_time(current_iteration),
      rejection_rate: current_iteration.rejection_rate,
      burnup_data: burnup_data(current_iteration),
      releases: upcoming_releases,
      labels: label_data(current_iteration),
      delivered_stories: delivered_stories(current_iteration),
      finished_stories: finished_stories(current_iteration),
      started_stories: started_stories(current_iteration)
    }
  end

  def iteration_options(past_iterations, current_iteration)
    options = []

    if current_iteration
      options << {
        value: current_iteration.id,
        text: current_iteration.display_name
      }
    end

    past_iterations.each do |iteration|
      options << {
        value: iteration.id,
        text: iteration.display_name
      }
    end

    options
  end

  def current_iteration_points_accepted(iteration)
    iteration&.stories&.accepted&.sum(:points) || 0
  end

  def current_iteration_stories_accepted(iteration)
    iteration&.stories&.accepted&.count || 0
  end

  def average_cycle_time(iteration)
    return "--" unless iteration

    stories = iteration.stories.accepted
    return "--" if stories.empty?

    total_days = stories.sum do |story|
      (story.accepted_at.to_date - story.started_at.to_date).to_i
    end

    average_days = total_days.to_f / stories.count
    "#{average_days.round(1)} days"
  end

  def burnup_data(iteration)
    return empty_burnup_data unless iteration

    dates = (iteration.start_date..iteration.end_date).to_a
    scope_data = []
    accepted_data = []

    current_scope = 0
    current_accepted = 0

    dates.each do |date|
      current_scope += iteration.stories.where("started_at <= ?", date.end_of_day).sum(:points)
      current_accepted += iteration.stories.where("accepted_at <= ?", date.end_of_day).sum(:points)

      scope_data << current_scope
      accepted_data << current_accepted
    end

    {
      dates: dates,
      scope: scope_data,
      accepted: accepted_data,
      expected: expected_burnup_line(dates.count)
    }
  end

  def empty_burnup_data
    {
      dates: [],
      scope: [],
      accepted: [],
      expected: []
    }
  end

  def expected_burnup_line(days)
    total_points = @project.current_scope
    return [] if total_points.zero? || days.zero?

    increment = total_points.to_f / (days - 1)
    (0...days).map { |i| (increment * i).round(2) }
  end

  def upcoming_releases
    return []
    @project.releases.upcoming.map do |release|
      {
        name: release.name,
        scheduled: release.scheduled_at.strftime("%b %d, %Y"),
        completion: release.expected_completion.strftime("%b %d, %Y")
      }
    end
  end

  def label_data(iteration)
    return [] unless iteration

    iteration.stories.joins(:labels)
             .group('labels.name', 'labels.color')
             .sum(:points)
             .map do |(name, color), points|
               {
                 name: name,
                 points: points,
                 color: color
               }
             end
  end

  def delivered_stories(iteration)
    iteration&.stories&.delivered&.map do |story|
      {
        id: story.id,
        name: story.name,
        points: story.points,
        owner: story.owner_initials
      }
    end || []
  end

  def finished_stories(iteration)
    iteration&.stories&.finished&.map do |story|
      {
        id: story.id,
        name: story.name,
        points: story.points,
        owner: story.owner_initials
      }
    end || []
  end

  def started_stories(iteration)
    iteration&.stories&.started&.map do |story|
      {
        id: story.id,
        name: story.name,
        points: story.points,
        owner: story.owner_initials,
        labels: story.labels.pluck(:name)
      }
    end || []
  end
end
