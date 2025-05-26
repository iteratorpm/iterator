class Task < ApplicationRecord
  belongs_to :story

  validates :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[
      description
      completed
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      story
    ]
  end
end
