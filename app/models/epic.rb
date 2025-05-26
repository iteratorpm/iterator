class Epic < ApplicationRecord
  belongs_to :project, counter_cache: true
  belongs_to :label, optional: true
  has_many :stories, through: :label

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates :name, presence: true
  validates :project, presence: true

  positioned on: :project

  # State scopes for stories
  scope :with_stories_in_state, ->(state) { joins(:stories).where(stories: { state: state }) }
  scope :ranked, -> { order(position: :asc) }

  before_create :set_project_epic_id

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      name
      description
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[stories]
  end

  def total_points
    stories.sum(:estimate)
  end

  def accepted_points
    stories.accepted.sum(:estimate)
  end

  def in_progress_points
    stories.current.sum(:estimate)
  end

  def unstarted_points
    stories.backlog.sum(:estimate)
  end

  def iceboxed_points
    stories.icebox.sum(:estimate)
  end

  def completion_percentage
    return 0 if total_points.zero?
    ((accepted_points.to_f / total_points) * 100).round
  end

  private
  def set_project_epic_id
    max_id = project.epics.maximum(:project_epic_id) || 0
    self.project_epic_id = max_id + 1
  end
end
