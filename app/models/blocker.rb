class Blocker < ApplicationRecord
  belongs_to :story
  belongs_to :blocker_story, class_name: 'Story', optional: true

  validates :description, presence: true
end
