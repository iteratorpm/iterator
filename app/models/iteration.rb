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

  validates :project, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :velocity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

  validate :end_date_after_start_date

  before_validation :set_dates, if: -> { start_date.blank? && project.present? }

  def self.find_or_create_current_iteration(project)
    Time.use_zone(project.time_zone) do
      iteration = project.iterations.current.first

      unless iteration
        # Find the most recent iteration that hasn't ended yet
        iteration = project.iterations.for_date(Time.zone.today).first

        unless iteration
          # Create a new current iteration if none exists
          iteration = project.create_current_iteration
        end
      end

      iteration
    end
  end

  def points_accepted
    stories.where(state: 'accepted').sum(:estimate)
  end

  def length_in_weeks
    ((end_date - start_date).to_i + 1) / 7
  end

  def points_remaining
    total_points - points_accepted
  end

  def completion_percentage
    return 0 if total_points.zero?
    ((points_accepted.to_f / total_points) * 100).round
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
    return false if velocity.nil?

    total_points >= velocity
  end

  def calculated_velocity
    update! velocity: project.calculated_velocity
  end

  # Move stories from backlog to this iteration until it's full
  def fill_from_backlog
    if self.current
      # fill everything that has started
      available_stories = project.stories
        .current

      available_stories.each do |story|
        story.update(iteration: self)
      end

      return
    end

    return if full? || !project.automatic_planning?

    # Get unstarted stories from backlog, ordered by priority
    available_stories = project.stories
                                .backlog
                                .ranked

    available_stories.each do |story|
      break if full?
      next if !story.estimated? # Skip unestimated stories unless they're bugs/chores

      story.update(iteration: self)
    end

    # Allow unestimated bugs/chores to be added even if iteration is full
    unless total_points >= velocity
      available_stories.unestimated.each do |story|
        story.update(iteration: self)
      end
    end
  end

  def complete!
    update!(current: false)
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

  def current?(project)
    Time.use_zone(project.time_zone) do
      now = Time.current
      start_date <= now && end_date >= now
    end
  end

  def past?(project)
    Time.use_zone(project.time_zone) do
      end_date < Time.current
    end
  end

  def future?(project)
    Time.use_zone(project.time_zone) do
      start_date > Time.current
    end
  end

  def duration
    (end_date - start_date).to_i + 1
  end

  def to_s
    Time.use_zone(project.time_zone) do
      "Iteration ##{number}: #{start_date.in_time_zone.strftime('%b %d')} - #{end_date.in_time_zone.strftime('%b %d')}"
    end
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
    Time.use_zone(project.time_zone) do
      if current?(project)
        "#{start_date.in_time_zone.strftime('%b %d')} – #{end_date.in_time_zone.strftime('%b %d')} (current)"
      else
        "#{start_date.in_time_zone.strftime('%b %d')} – #{end_date.in_time_zone.strftime('%b %d')} (##{number})"
      end
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
      self.start_date = (project.start_date || project.calculate_iteration_start_date)
    end

    self.end_date = start_date + (project.iteration_length || 1).weeks - 1.day
    self.number = last_iteration ? last_iteration.number + 1 : 1
  end

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
