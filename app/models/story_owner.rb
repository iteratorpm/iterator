class StoryOwner < ApplicationRecord
  belongs_to :story
  belongs_to :user

  validates :user_id, uniqueness: { scope: :story_id }
end
