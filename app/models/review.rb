class Review < ApplicationRecord
  belongs_to :story
  belongs_to :reviewer, class_name: 'User'

  validates :status, presence: true
  enum status: { requested: 0, approved: 1, rejected: 2 }
end
