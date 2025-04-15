class Label < ApplicationRecord
  belongs_to :project
  has_many :story_labels, dependent: :destroy
  has_many :stories, through: :story_labels

  validates :name, presence: true, uniqueness: { scope: :project_id }
end
