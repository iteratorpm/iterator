class DescriptionTemplate < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, length: { maximum: 30 }
  validates :description, presence: true, length: { maximum: 20000 }
end
