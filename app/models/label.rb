class Label < ApplicationRecord
  belongs_to :project
  has_many :story_labels, dependent: :destroy
  has_many :stories, through: :story_labels

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[stories]
  end

  validates :name, presence: true, uniqueness: { scope: :project_id }
end
