class User < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    %w[
      name
      email
      username
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      requested_stories
      owned_stories
    ]
  end

  has_many :favorites
  has_many :muted_projects
  has_one :notification_setting
  has_many :notifications
  has_many :favorite_projects, through: :favorites, source: :project
  has_many :authored_comments, class_name: 'Comment', foreign_key: 'author_id', dependent: :nullify
  has_many :uploaded_attachments, class_name: 'Attachment', foreign_key: 'uploader_id', dependent: :nullify
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :requested_stories, class_name: 'Story', foreign_key: 'requester_id'

  has_and_belongs_to_many :owned_stories, class_name: 'Story'
  has_one_attached :avatar

  belongs_to :current_organization, class_name: 'Organization', optional: true

  # Include default devise modules. Others available are:
  devise_modules = [
    :invitable,
    :database_authenticatable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable
  ]

  devise_modules << :registerable unless ENV["DISABLE_REGISTRATION"] == "true"

  devise(*devise_modules)

  validates :name, length: { minimum: 1, maximum: 30 }
  validates :username, length: { minimum: 1, maximum: 30 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  before_save :set_initials_if_blank

  def self.find_or_invite_by_email(email, invited_by=nil)
    user = find_by(email: email.downcase)
    return user if user

    temp_username = "user #{SecureRandom.hex(4)}"

    user = invite!({
      email: email.downcase,
      username: temp_username,
      name: temp_username
    }, invited_by)

    user
  end

  def find_or_create_notification_setting
    notification_setting || create_notification_setting
  end

  def add_to_organization(organization, role = :member)
    memberships.find_or_create_by!(organization: organization) do |m|
      m.role = role
    end
  end

  def owned_projects
    projects.merge(ProjectMembership.owner)
  end

  def member_projects
    projects.merge(ProjectMembership.member)
  end

  def viewer_projects
    projects.merge(ProjectMembership.viewer)
  end

  def owned_organizations
    organizations.joins(:memberships).where(memberships: { role: :owner })
  end

  def admin_organizations
    organizations.joins(:memberships).where(memberships: { role: :admin })
  end

  def project_creator_organizations
    organizations.joins(:memberships).where(memberships: { role: [:owner, :admin, :project_creator] })
  end

  # Check if user can create projects in an organization
  def can_create_projects_in?(organization)
    organization.memberships.where(user_id: id, role: [:owner, :admin, :project_creator]).exists?
  end

  def authorized_apps
    []
  end

  def regenerate_api_token
    update(api_token: SecureRandom.hex(16))
  end

  def invitation_pending?
    invitation_accepted_at.nil? && invitation_sent_at.present?
  end

  def clear_api_token!
    update(api_token: nil)
  end

  def avatar_url
    avatar.attached? ? Rails.application.routes.url_helpers.rails_representation_url(
      avatar.variant(resize_to_fill: [48, 48]).processed,
      only_path: true
    ) : nil
  end

  private

  def set_initials_if_blank
    if initials.blank? && name.present?
      self.initials = name.split.map(&:first).join.upcase
    end
  end

end
