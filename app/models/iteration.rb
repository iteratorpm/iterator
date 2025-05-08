class Iteration < ApplicationRecord

  enum :state, {
    backlog: 0,
    current: 1,
    done: 2
  }

  scope :current, -> { where(state: :current) }
  scope :backlog, -> { where(state: :backlog) }
  scope :done, -> { where(state: :done) }
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
  before_save :set_points_completed, if: :done?
  after_update :trigger_recalculation, if: :saved_change_to_team_strength?

  def self.find_or_create_current_iteration(project)
    IterationPlanner.find_or_create_current_iteration(project)
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
    stories.estimated.sum(:estimate)
  end

  # Check if the iteration is full based on project velocity
  def full?
    return false if velocity.nil?

    total_points >= velocity
  end

  def complete!
    update!(state: :done)
  end

  def points_accepted
    stories.estimated.accepted.sum(:estimate)
  end

  def rejection_rate
    completed_stories = stories.where(state: ['accepted', 'rejected'])
    return 0.0 if completed_stories.empty?

    rejected_count = completed_stories.where(state: 'rejected').count
    (rejected_count.to_f / completed_stories.count * 100).round(1)
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
      if current?
        "#{start_date.in_time_zone.strftime('%b %d')} – #{end_date.in_time_zone.strftime('%b %d')} (current)"
      else
        "#{start_date.in_time_zone.strftime('%b %d')} – #{end_date.in_time_zone.strftime('%b %d')} (##{number})"
      end
    end
  end

  private

  def set_points_completed
    if points_completed.zero?
      points_completd = points_accepted
    end
  end

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

  def trigger_recalculation
    project.recalculate_iterations
  end
end
