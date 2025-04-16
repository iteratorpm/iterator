class User < ApplicationRecord

  has_many :authored_comments, class_name: 'Comment', foreign_key: 'author_id', dependent: :nullify
  has_many :uploaded_attachments, class_name: 'Attachment', foreign_key: 'uploader_id', dependent: :nullify
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  belongs_to :current_organization, class_name: 'Organization', optional: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, length: { minimum: 0, maximum: 30 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

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

  private

  def set_initials_if_blank
    if initials.blank? && username.present?
      self.initials = username[0, 2].upcase
    end
  end
end
