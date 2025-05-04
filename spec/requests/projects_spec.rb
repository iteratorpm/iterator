require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:organization) { create(:organization) }
  let(:member) { create(:user) }

  login_user

  before do
    create :membership, user: current_user, organization: organization, role: :owner
    current_user.update(current_organization_id: organization.id)
  end

  describe "GET /projects", focus: true do
    it "requires authentication" do
      sign_out current_user
      get projects_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns http success" do
      create_list(:project, 3, organization: organization)
      get projects_path
      expect(response).to have_http_status(:success)
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
        velocity_strategy: "past_iters_1",
        initial_velocity: 10,
        iteration_length: 1,
        done_iterations_to_show: 4
      )
    end

    it "loads user organizations" do
      org2 = create(:organization)
      current_user.organizations << org2
      get new_project_path
      expect(assigns(:organizations)).to match_array([organization, org2])
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

    let(:invalid_attributes) do
      {
        project: {
          name: "",
          organization_id: organization.id
        }
      }
    end

    context "with valid parameters" do
      it "creates a new Project" do
        expect {
          post projects_path, params: valid_attributes
        }.to change(Project, :count).by(1)
      end

      it "assigns current organization if not specified" do
        post projects_path, params: valid_attributes.except(:organization_id)
        expect(assigns(:project).organization).to eq(organization)
      end

      it "creates project membership for current user as owner" do
        post projects_path, params: valid_attributes
        project = Project.last
        membership = project.memberships.find_by(user: current_user)
        expect(membership.owner?).to be true
      end

      it "redirects to the created project" do
        post projects_path, params: valid_attributes
        expect(response).to redirect_to(project_path(Project.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Project" do
        expect {
          post projects_path, params: invalid_attributes
        }.not_to change(Project, :count)
      end

      it "renders new template with unprocessable_entity status" do
        post projects_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end

      it "loads organizations for the form" do
        post projects_path, params: invalid_attributes
        expect(assigns(:organizations)).to eq([organization])
      end
    end

    context "when unauthorized" do
      it "does not allow creating project for organization user doesn't belong to" do
        other_org = create(:organization)
        post projects_path, params: {
          project: valid_attributes[:project].merge(organization_id: other_org.id)
        }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /projects/:id" do
    let(:project) { create(:project, organization: organization) }

    it "returns http success" do
      get project_path(project)
      expect(response).to have_http_status(:success)
    end

    context "when user is org admin" do
      it "returns http success" do
        current_user.memberships.destroy_all

        create :membership, user: current_user, organization: organization, role: :admin

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

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /projects/:id/edit" do
    let(:project) { create(:project, organization: organization) }

    it "returns http success" do
      get edit_project_path(project)
      expect(response).to have_http_status(:success)
    end

    it "loads organizations for the form" do
      get edit_project_path(project)
      expect(assigns(:organizations)).to eq([organization])
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.memberships.create(user: member, role: :viewer)
        sign_in member
        get edit_project_path(project)

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PATCH /projects/:id" do
    let(:project) { create(:project, organization: organization) }
    let(:new_attributes) do
      {
        name: "Updated Project Title",
        description: "Updated description",
        iteration_length: 3,
        point_scale: "tshirt_sizes"
      }
    end

    context "with valid parameters" do
      it "updates the requested project" do
        patch project_path(project), params: { project: new_attributes }
        project.reload
        expect(project.name).to eq("Updated Project Title")
        expect(project.description).to eq("Updated description")
        expect(project.iteration_length).to eq(3)
      end

      it "redirects to the project" do
        patch project_path(project), params: { project: new_attributes }
        expect(response).to redirect_to(project_path(project))
      end
    end

    context "with invalid parameters" do
      it "renders edit template with unprocessable_entity status" do
        patch project_path(project), params: { project: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end

      it "loads organizations for the form" do
        patch project_path(project), params: { project: { name: "" } }
        expect(assigns(:organizations)).to eq([organization])
      end
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.memberships.create(user: member, role: :viewer)
        sign_in member
        patch project_path(project), params: { project: new_attributes }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "DELETE /projects/:id" do
    let!(:project) { create(:project, organization: organization) }

    it "destroys the requested project" do
      expect {
        delete project_path(project)
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      delete project_path(project)
      expect(response).to redirect_to(projects_url)
    end

    context "when unauthorized" do
      it "denies access to non-owners" do
        project.memberships.create(user: member, role: :member)
        sign_in member
        delete project_path(project)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
