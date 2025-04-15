class User < ApplicationRecord

  has_many :authored_comments, class_name: 'Comment', foreign_key: 'author_id', dependent: :nullify
  has_many :uploaded_attachments, class_name: 'Attachment', foreign_key: 'uploader_id', dependent: :nullify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, length: { minimum: 0, maximum: 30 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  before_save :set_initials_if_blank

  private

  def set_initials_if_blank
    if initials.blank? && username.present?
      self.initials = username[0, 2].upcase
    end
  end
end
