class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: 'User'

  has_many :attachments, as: :attachable, dependent: :destroy

  validates :content, presence: true
  validates :author, presence: true

  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :by_author, ->(user_id) { where(author_id: user_id) }

  # Allow for @mentions in comments
  after_create :process_mentions

  private

  def process_mentions
    # Logic to extract @mentions from content and notify users
    # Implementation depends on your notification system
  end
end
