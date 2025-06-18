require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:organization) { create(:organization) }
  let(:member) { create(:user) }
  let(:admin) { create(:user) }
  let(:non_member) { create(:user) }

  login_user

  before do
    create :membership, user: current_user, organization: organization, role: :owner
    create :membership, user: admin, organization: organization, role: :admin
    current_user.update(current_organization_id: organization.id)
  end

  describe "GET /projects" do
    context "when authenticated" do
      let!(:active_project) { create(:project, organization: organization) }
      let!(:archived_project) { create(:project, organization: organization, archived: true) }
      let!(:favorite_project) { create(:project, organization: organization) }

      before do
        create :project_membership, user: current_user, project: active_project
        create :project_membership, user: current_user, project: archived_project
        create :project_membership, user: current_user, project: favorite_project

        current_user.favorite_projects << favorite_project
      end

      it "returns http success" do
        get projects_path
        expect(response).to have_http_status(:success)
      end

      it "assigns active projects" do
        get projects_path
        expect(assigns(:active_projects)).to eq([active_project, favorite_project])
      end

      it "assigns archived projects" do
        get projects_path
        expect(assigns(:archived_projects)).to eq([archived_project])
      end

      it "assigns favorite projects" do
        get projects_path
        expect(assigns(:favorite_projects)).to eq([favorite_project])
      end
    end

    it "requires authentication" do
      sign_out current_user
      get projects_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /projects/new" do
    it "returns http success" do
      get new_project_path
      expect(response).to have_http_status(:success)
    end

    it "initializes project with default values" do
      get new_project_path
      expect(assigns(:project)).to have_attributes(
        iteration_start_day: "monday",
        time_zone: "Eastern Time (US & Canada)",
        point_scale: "linear_0123",
        velocity_strategy: "past_iters_3",
        initial_velocity: 10,
        iteration_length: 2,
        done_iterations_to_show: 4,
        organization_id: organization.id
      )
    end

    it "loads user organizations" do
      org2 = create(:organization)
      current_user.organizations << org2
      get new_project_path
      expect(assigns(:organizations)).to match_array([organization, org2])
    end

    context "when no org" do
      it "allows access to users without an org" do
        sign_in non_member
        get new_project_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /projects" do
    let(:valid_attributes) do
      {
        project: {
          name: "New Project",
          description: "Project description",
          organization_id: organization.id,
          public: false,
          iteration_start_day: :tuesday,
          start_date: Date.today,
          time_zone: "UTC",
          iteration_length: 2,
          point_scale: "fibonacci",
          initial_velocity: 8,
          velocity_strategy: "past_iters_2"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new Project" do
        expect {
          post projects_path, params: valid_attributes
        }.to change(Project, :count).by(1)
      end

      it "creates project membership for current user as owner" do
        post projects_path, params: valid_attributes
        project = Project.last
        membership = project.project_memberships.find_by(user: current_user)
        expect(membership.owner?).to be true
      end

      it "redirects to the created project" do
        post projects_path, params: valid_attributes
        expect(response).to redirect_to(project_path(Project.last))
      end
    end

    context "when unauthorized" do
      it "denies access to users without create permission" do
        sign_in non_member
        post projects_path, params: valid_attributes
        expect(response).to be_access_denied
      end

      it "denies creating project for organization user doesn't belong to" do
        other_org = create(:organization)
        post projects_path, params: {
          project: valid_attributes[:project].merge(organization_id: other_org.id)
        }
        expect(response).to be_access_denied
      end
    end
  end

  describe "GET /projects/:id" do
    let(:project) { create(:project, organization: organization) }

    context "when user is project member" do
      before { project.project_memberships.create(user: current_user, role: :viewer) }

      it "returns http success" do
        get project_path(project)
        expect(response).to have_http_status(:success)
      end

      it "sets active_panel from cookies" do
        cookies[:active_panel] = "custom_panel"
        get project_path(project)
        expect(assigns(:active_panel)).to eq("custom_panel")
      end
    end

    context "when user is org admin" do
      before { sign_in admin }

      it "returns http success" do
        get project_path(project)
        expect(response).to have_http_status(:success)
      end
    end

    context "when project is public" do
      let(:project) { create(:project, organization: organization, public: true) }

      it "allows access to unauthenticated users" do
        sign_out current_user
        get project_path(project)
        expect(response).to have_http_status(:success)
      end
    end

    context "when unauthorized" do
      it "denies access to users not in organization" do
        other_project = create(:project)
        get project_path(other_project)
        expect(response).to be_access_denied
      end
    end
  end

  describe "GET /projects/:id/edit" do
    let(:project) { create(:project, organization: organization) }

    context "when user is project owner" do
      before { project.project_memberships.create(user: current_user, role: :owner) }

      it "returns http success" do
        get edit_project_path(project)
        expect(response).to have_http_status(:success)
      end

      it "loads organizations for the form" do
        get edit_project_path(project)
        expect(assigns(:organizations)).to eq([organization])
      end
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.project_memberships.create(user: member, role: :member)
        sign_in member
        get edit_project_path(project)
        expect(response).to be_access_denied
      end

    end

    context "when org admin" do
      it "allows access to org admins" do
        sign_in admin
        get edit_project_path(project)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /projects/:id" do
    let(:project) { create(:project, organization: organization) }
    let(:valid_attributes) do
      {
        name: "Updated Name",
        description: "Updated description",
        public: true,
        enable_tasks: true,
        iteration_start_day: "friday",
        start_date: Date.today + 1.week,
        time_zone: "Pacific Time (US & Canada)",
        iteration_length: 3,
        point_scale: "fibonacci",
        point_scale_custom: "1,2,4,8",
        initial_velocity: 5,
        velocity_strategy: "past_iters_3",
        done_iterations_to_show: 2,
        automatic_planning: true,
        allow_api_access: true,
        enable_incoming_emails: true,
        hide_email_addresses: true,
        priority_field_enabled: true,
        priority_display_scope: "all_panels",
        point_bugs_and_chores: true
      }
    end

    before { project.project_memberships.create(user: current_user, role: :owner) }

    it "updates all permitted attributes" do
      patch project_path(project), params: { project: valid_attributes }
      project.reload
      valid_attributes.each do |attr, value|
        expect(project.send(attr)).to eq(value)
      end
    end

    context "when updating point_scale to custom" do
      it "requires point_scale_custom" do
        patch project_path(project), params: {
          project: valid_attributes.merge(point_scale: "custom", point_scale_custom: nil)
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.project_memberships.create(user: member, role: :member)
        sign_in member
        patch project_path(project), params: { project: { name: "New Name" } }
        expect(response).to be_access_denied
      end
    end
  end

  describe "POST /projects/:id/archive" do
    let(:project) { create(:project, organization: organization) }

    context "when user is owner" do
      before { project.project_memberships.create(user: current_user, role: :owner) }

      it "archives the project" do
        post archive_project_path(project)
        expect(project.reload.archived).to be true
      end

      it "redirects to edit project" do
        post archive_project_path(project)
        expect(response).to redirect_to(edit_project_path(project))
      end
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.project_memberships.create(user: member, role: :member)
        sign_in member
        post archive_project_path(project)
        expect(response).to be_access_denied
      end
    end
  end

  describe "POST /projects/:id/unarchive" do
    let(:project) { create(:project, organization: organization, archived: true) }

    context "when user is owner" do
      before { project.project_memberships.create(user: current_user, role: :owner) }

      it "unarchives the project" do
        post unarchive_project_path(project)
        expect(project.reload.archived).to be false
      end
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.project_memberships.create(user: member, role: :member)
        sign_in member
        post unarchive_project_path(project)
        expect(response).to be_access_denied
      end
    end
  end

  describe "DELETE /projects/:id" do
    let!(:project) { create(:project, organization: organization) }

    context "when user is owner" do
      before { project.project_memberships.create(user: current_user, role: :owner) }

      it "destroys the project" do
        expect {
          delete project_path(project)
        }.to change(Project, :count).by(-1)
      end

      it "redirects to projects list" do
        delete project_path(project)
        expect(response).to redirect_to(projects_url)
      end
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.project_memberships.create(user: member, role: :member)
        sign_in member
        delete project_path(project)
        expect(response).to be_access_denied
      end
    end
  end
end
