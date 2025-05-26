class Label < ApplicationRecord
  belongs_to :project
  has_one :epic

  enum :label_type, { regular: 0, epic: 1 }

  has_many :story_labels, dependent: :destroy
  has_many :stories, through: :story_labels

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[stories]
  end

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :project, presence: true

  before_destroy :ensure_not_epic_label

  private
  def ensure_not_epic_label
    throw(:abort) if epic_id.present?
  end
end
