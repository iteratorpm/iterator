require 'rails_helper'

RSpec.describe "Organizations", type: :request do
  let(:admin) { create(:user) }
  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, user: admin, organization: organization, role: :admin) }
  let(:owner_membership) { create(:membership, user: owner, organization: organization, role: :owner) }
  let(:member_membership) { create(:membership, user: member, organization: organization, role: :member) }

  before do
    owner_membership
    admin_membership
    member_membership
  end

  describe "GET /organizations" do
    context "as an admin" do
      before { sign_in admin }

      it "returns http success" do
        get organizations_path
        expect(response).to have_http_status(:success)
      end

      it "returns organizations as JSON" do
        get organizations_path(format: :json)
        expect(response).to have_http_status(:success)
        expect(json_response).to be_an(Array)
      end
    end

    context "as a member" do
      before { sign_in member }

      it "returns http success" do
        get organizations_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as unauthorized user" do
      before { sign_out other_user }

      it "redirects to root" do
        get organizations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /organizations/:id" do
    context "as an admin" do
      before { sign_in admin }

      it "returns http success" do
        get organization_path(organization)
        expect(response).to have_http_status(:success)
      end

      it "returns organization as JSON" do
        get organization_path(organization, format: :json)
        expect(response).to have_http_status(:success)
        expect(json_response['id']).to eq(organization.id)
      end
    end

    context "as a member" do
      before { sign_in member }

      it "returns http success" do
        get organization_path(organization)
        expect(response).to have_http_status(:success)
      end
    end

    context "as unauthorized user" do
      before { sign_in other_user }

      it "redirects to root" do
        get organization_path(organization)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /organizations/:id/plans_and_billing" do
    context "as an admin" do
      before { sign_in owner }

      it "returns http success" do
        get plans_and_billing_organization_path(organization)
        expect(response).to have_http_status(:success)
      end
    end

    context "as a member" do
      before { sign_in member }

      it "redirects to root" do
        get plans_and_billing_organization_path(organization)
        expect(response).to redirect_to(root_path)
      end
    end

    context "as a admin" do
      before { sign_in admin }

      it "redirects to root" do
        get plans_and_billing_organization_path(organization)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /organizations/:id/projects" do
    before { sign_in admin }

    it "returns active projects by default" do
      active_project = create(:project, organization: organization, archived: false)
      archived_project = create(:project, organization: organization, archived: true)

      get projects_organization_path(organization)
      expect(assigns(:projects)).to include(active_project)
      expect(assigns(:projects)).not_to include(archived_project)
    end

    it "returns archived projects when requested" do
      active_project = create(:project, organization: organization, archived: false)
      archived_project = create(:project, organization: organization, archived: true)

      get projects_organization_path(organization, archived: "true")
      expect(assigns(:projects)).to include(archived_project)
      expect(assigns(:projects)).not_to include(active_project)
    end
  end

  describe "GET /organizations/:id/memberships" do
    before { sign_in admin }

    it "returns organization memberships" do
      get organization_memberships_path(organization)
      expect(assigns(:memberships)).to include(admin_membership, member_membership)
    end
  end

  describe "GET /organizations/:id/project_report" do
    before { sign_in admin }

    it "returns JSON report" do
      get project_report_organization_path(organization, format: :json)
      expect(response).to have_http_status(:success)
      expect(json_response['id']).to eq(organization.id)
    end

    it "returns CSV report" do
      get project_report_organization_path(organization, format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/csv')
    end
  end

  describe "POST /organizations" do
    context "with valid params" do
      before { sign_in owner }

      let(:valid_params) { { organization: { name: "New Org" } } }

      it "creates a new organization" do
        expect {
          post organizations_path, params: valid_params
        }.to change(Organization, :count).by(1)
      end

      it "redirects to projects with notice" do
        post organizations_path, params: valid_params
        expect(response).to redirect_to(projects_path)
        expect(flash[:notice]).to eq('Organization was successfully created.')
      end

      it "creates JSON response" do
        post organizations_path(format: :json), params: valid_params
        expect(response).to have_http_status(:created)
        expect(json_response['name']).to eq('New Org')
      end

      it "sets current organization if not set" do
        owner.update(current_organization_id: nil)
        post organizations_path, params: valid_params
        expect(owner.reload.current_organization_id).not_to be_nil
      end
    end

    context "with invalid params" do
      before { sign_in owner }

      let(:invalid_params) { { organization: { name: "" } } }

      it "does not create organization" do
        expect {
          post organizations_path, params: invalid_params
        }.not_to change(Organization, :count)
      end

      it "renders new template" do
        post organizations_path, params: invalid_params
        expect(response).to render_template(:new)
      end

      it "returns JSON errors" do
        post organizations_path(format: :json), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe "PATCH /organizations/:id" do
    before { sign_in admin }

    context "with valid params" do
      let(:valid_params) { { organization: { name: "Updated Name" } } }

      it "updates organization" do
        patch organization_path(organization), params: valid_params
        expect(organization.reload.name).to eq('Updated Name')
      end

      it "redirects with notice" do
        patch organization_path(organization), params: valid_params
        expect(response).to redirect_to(organization)
        expect(flash[:notice]).to eq('Organization was successfully updated.')
      end

      it "returns JSON response" do
        patch organization_path(organization, format: :json), params: valid_params
        expect(response).to have_http_status(:success)
        expect(json_response['name']).to eq('Updated Name')
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { organization: { name: "" } } }

      it "does not update organization" do
        original_name = organization.name
        patch organization_path(organization), params: invalid_params
        expect(organization.reload.name).to eq(original_name)
      end

      it "renders edit template" do
        patch organization_path(organization), params: invalid_params
        expect(response).to render_template(:edit)
      end

      it "returns JSON errors" do
        patch organization_path(organization, format: :json), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe "DELETE /organizations/:id" do
    before { sign_in owner }

    context "when not default organization" do
      it "destroys organization" do
        delete organization_path(organization)
        expect(Organization.exists?(organization.id)).to be_falsey
      end

      it "redirects with notice" do
        delete organization_path(organization)
        expect(response).to redirect_to(organizations_url)
        expect(flash[:notice]).to eq('Organization was successfully destroyed.')
      end

      it "returns no content for JSON" do
        delete organization_path(organization, format: :json)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when default organization" do
      before { owner.update(current_organization_id: organization.id) }

      it "does not destroy organization" do
        delete organization_path(organization)
        expect(Organization.exists?(organization.id)).to be_truthy
      end

      it "redirects with alert" do
        delete organization_path(organization)
        expect(response).to redirect_to(organizations_url)
        expect(flash[:alert]).to eq('Cannot delete your default organization. Please set another organization as default first.')
      end

      it "returns JSON error" do
        delete organization_path(organization, format: :json)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Cannot delete default organization')
      end
    end
  end

end
