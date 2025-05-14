class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: 'User'

  def self.ransackable_attributes(auth_object = nil)
    %w[content created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[commentable author]
  end

  has_many :attachments, as: :attachable, dependent: :destroy

  validates :content, presence: true
  validates :author, presence: true

  # Scopes
  scope :newest_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :by_author, ->(user_id) { where(author_id: user_id) }

  # Allow for @mentions in comments
  after_create :notify_mentioned_users

  private

  def notify_mentioned_users
    mentioned_users.each do |user|
      NotificationService.notify(user, :mention_in_comment, self)
    end
  end
end
