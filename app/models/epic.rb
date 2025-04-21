class Epic < ApplicationRecord
  belongs_to :project
  has_many :stories, dependent: :nullify
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates :name, presence: true
  validates :project, presence: true

  # State scopes for stories
  scope :with_stories_in_state, ->(state) { joins(:stories).where(stories: { state: state }) }

  def total_points
    stories.sum(:estimate)
  end

  def accepted_points
    stories.where(state: 'accepted').sum(:estimate)
  end

  def in_progress_points
    stories.where(state: %w[started finished delivered]).sum(:estimate)
  end

  def unstarted_points
    stories.where(state: 'unstarted').sum(:estimate)
  end

  def iceboxed_points
    stories.where(state: 'icebox').sum(:estimate)
  end

  def completion_percentage
    return 0 if total_points.zero?
    ((accepted_points.to_f / total_points) * 100).round
  end
end
