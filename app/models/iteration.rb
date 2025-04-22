class Iteration < ApplicationRecord
  scope :current, -> {
    now = Time.current
    where("start_date <= ? AND end_date >= ?", now, now)
  }

  scope :past, -> { completed.order(start_date: :desc) }
  scope :in_range, ->(start_date, end_date) {
    where("start_date >= ? AND end_date <= ?", start_date, end_date)
  }

  scope :current, -> { where(current: true) }
  scope :backlog, -> { where("start_date > ?", Date.current).order(:start_date) }
  scope :done, -> { where("end_date < ?", Date.current).order(start_date: :desc) }
  scope :for_date, ->(date) { where("start_date <= ? AND end_date >= ?", date, date) }

  belongs_to :project
  has_many :stories, dependent: :nullify

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :velocity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_dates, if: -> { start_date.blank? && project.present? }

  def self.current_iteration(project)
    iteration = project.iterations.current.first

    unless iteration
      # Find the most recent iteration that hasn't ended yet
      iteration = project.iterations.for_date(Date.current).first

      unless iteration
        # Create a new current iteration if none exists
        iteration = project.create_current_iteration
      end
    end

    iteration
  end

  def completed_points
    stories.where(state: 'accepted').sum(:estimate)
  end

  def points_remaining
    total_points - completed_points
  end

  def completion_percentage
    return 0 if total_points.zero?
    ((completed_points.to_f / total_points) * 100).round
  end

  def progress_width
    completion_percentage.clamp(0, 100)
  end

  # Calculate the total points of all stories in this iteration
  def total_points
    stories.sum(:estimate)
  end

  # Check if the iteration is full based on project velocity
  def full?
    return false unless project.velocity.present?
    total_points >= project.velocity
  end

  # Move stories from backlog to this iteration until it's full
  def fill_from_backlog
    return if full? || !project.automatic_planning?

    # Get unstarted stories from backlog, ordered by priority
    available_stories = project.stories.backlog.unstarted.ranked

    available_stories.each do |story|
      break if full?
      next unless story.estimated? # Skip unestimated stories unless they're bugs/chores

      story.update(iteration: self)
    end

    # Allow unestimated bugs/chores to be added even if iteration is full
    unless project.velocity.present? && total_points >= project.velocity
      available_stories.unestimated.each do |story|
        story.update(iteration: self)
      end
    end
  end

  # Move accepted stories to done when iteration ends
  def complete!
    return unless end_date <= Date.current

    transaction do
      stories.accepted.each do |story|
        story.update(iteration: nil, state: 'done')
      end
      update(current: false)
    end
  end

  def points_accepted
    stories.accepted.sum(:points)
  end

  def rejection_rate
    completed_stories = stories.where(status: ['accepted', 'rejected'])
    return 0.0 if completed_stories.empty?

    rejected_count = completed_stories.where(status: 'rejected').count
    (rejected_count.to_f / completed_stories.count * 100).round(1)
  end

  def current?
    now = Time.current
    start_date <= now && end_date >= now
  end

  def past?
    end_date < Time.current
  end

  def future?
    start_date > Time.current
  end

  def duration
    (end_date - start_date).to_i + 1
  end

  def to_s
    "Iteration ##{number}: #{start_date.strftime('%b %d')} - #{end_date.strftime('%b %d')}"
  end

  def override?
    length_weeks.present?
  end

  def shift!(weeks:)
    self.start_date += weeks.weeks
    self.end_date += weeks.weeks
    save!
  end

  def display_name
    if current?
      "#{start_date.strftime("%b %d")} – #{end_date} (current)"
    else
      "#{start_date.strftime("%b %d")} – #{end_date} (\##{number})"
    end
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def set_dates
    last_iteration = project.iterations.order(start_date: :desc).first

    if last_iteration
      self.start_date = last_iteration.end_date + 1.day
    else
      # First iteration starts on project start date or today
      self.start_date = project.start_date || Date.current
    end

    self.end_date = start_date + (project.iteration_length || 1).weeks - 1.day
    self.number = last_iteration ? last_iteration.number + 1 : 1
  end
end
