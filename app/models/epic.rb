class Epic < ApplicationRecord
  belongs_to :project
  has_many :stories, dependent: :nullify
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates :name, presence: true
  validates :project, presence: true
end
