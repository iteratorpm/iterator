class Task < ApplicationRecord
  belongs_to :story

  validates :description, presence: true
end
