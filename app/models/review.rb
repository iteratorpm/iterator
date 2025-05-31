class Review < ApplicationRecord
  belongs_to :story
  belongs_to :reviewer, class_name: 'User'

  validates :state, presence: true

  enum :state, { unstarted: 0, in_review: 1, pass: 2, revise: 3 }
end
