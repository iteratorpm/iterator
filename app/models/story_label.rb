class StoryLabel < ApplicationRecord
  belongs_to :story
  belongs_to :label

  validates :label_id, uniqueness: { scope: :story_id }
end
