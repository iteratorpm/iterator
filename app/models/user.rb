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
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, length: { minimum: 1, maximum: 30 }
  validates :username, length: { minimum: 1, maximum: 30 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  before_save :set_initials_if_blank

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

  def clear_api_token!
    update(api_token: nil)
  end

  private

  def set_initials_if_blank
    if initials.blank? && name.present?
      self.initials.split.map(&:first).join.upcase
    end
  end

end
