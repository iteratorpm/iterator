class MutedProject < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :mute_type, { all_notifications: 0, except_mentions: 1 }

  scope :for_user, ->(user) { where(user: user) }
  scope :for_project, ->(project) { where(project: project) }

  validates :user, presence: true
  validates :project, presence: true
end
