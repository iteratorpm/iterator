class ReviewType < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, length: { maximum: 25 }
  scope :visible, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }
end
