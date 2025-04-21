class Iteration < ApplicationRecord
  scope :current, -> {
    now = Time.current
    where("start_date <= ? AND end_date >= ?", now, now)
  }

  scope :completed, -> { where("end_date < ?", Time.current) }
  scope :upcoming, -> { where("start_date > ?", Time.current) }

  belongs_to :project

  def override?
    length_weeks.present?
  end

  def duration
    (end_date - start_date).to_i
  end

  def shift!(weeks:)
    self.start_date += weeks.weeks
    self.end_date += weeks.weeks
    save!
  end

  def display_name
    if current?
      "#{start_date.to_s(:short)} – #{end_date.to_s(:short)} (current)"
    else
      "#{start_date.to_s(:short)} – #{end_date.to_s(:short)} (##{number})"
    end
  end
end
