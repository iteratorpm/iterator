class Iteration < ApplicationRecord
  scope :current, -> {
    now = Time.current
    where("start_date <= ? AND end_date >= ?", now, now)
  }

  scope :past, -> { completed.order(start_date: :desc) }
  scope :completed, -> { where("end_date < ?", Time.current) }
  scope :upcoming, -> { where("start_date > ?", Time.current) }
  scope :in_range, ->(start_date, end_date) {
    where("start_date >= ? AND end_date <= ?", start_date, end_date)
  }

  belongs_to :project
  has_many :stories, dependent: :nullify

  validates :start_date, :end_date, :number, presence: true
  validate :end_date_after_start_date

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
end
