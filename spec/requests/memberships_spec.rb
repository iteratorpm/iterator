require 'rails_helper'

RSpec.describe.skip "Memberships", type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user) }
  let(:member) { create(:user) }
  let(:admin_membership) { create(:membership, user: admin, organization: organization, role: :admin) }
  let(:member_membership) { create(:membership, user: member, organization: organization, role: :member) }

  before do
    # Setup existing memberships
    admin_membership
    member_membership
    sign_in admin
  end

  describe "GET /organizations/:organization_id/memberships" do
    it "returns http success" do
      get organization_memberships_path(organization)
      expect(response).to have_http_status(:success)
    end

    context "with filters" do
      it "filters by admin role" do
        get organization_memberships_path(organization), params: { filter: 'admin' }
        expect(assigns(:memberships)).to eq([admin_membership])
      end

      it "filters by project creator" do
        project_creator = create(:membership, organization: organization, project_creator: true)
        get organization_memberships_path(organization), params: { filter: 'project_creator' }
        expect(assigns(:memberships)).to eq([project_creator])
      end

      it "filters by search term" do
        get organization_memberships_path(organization), params: { q: admin.name }
        expect(assigns(:memberships)).to eq([admin_membership])
      end

      it "hides non-collaborators" do
        project = create(:project, organization: organization)
        member = create(:membership, organization: organization, role: :member)
        get organization_memberships_path(organization), params: { hide_non_collaborators: '1' }
        expect(assigns(:memberships)).to_not include(member)
      end
    end
  end

  describe "GET /organizations/:organization_id/memberships/new" do
    it "returns http success" do
      get new_organization_membership_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:organization_id/memberships" do
    context "with existing user" do
      let(:existing_user) { create(:user) }

      it "creates a membership for existing user" do
        expect {
          post organization_memberships_path(organization), params: {
            membership: {
              email: existing_user.email,
              role: 'member',
              project_creator: false
            }
          }
        }.to change(Membership, :count).by(1)
        expect(response).to redirect_to(organization_memberships_path(organization))
        expect(flash[:notice]).to eq('Member was successfully added.')
      end

      it "fails with invalid params" do
        post organization_memberships_path(organization), params: {
          membership: {
            email: existing_user.email,
            role: 'invalid_role'
          }
        }
        expect(response).to render_template(:new)
      end
    end

    context "with new user" do
      it "renders new user form when email doesn't exist" do
        post organization_memberships_path(organization), params: {
          membership: {
            email: 'newuser@example.com',
            role: 'member'
          }
        }
        expect(response).to render_template(:new_user_form)
        expect(assigns(:email)).to eq('newuser@example.com')
      end
    end
  end

  describe "POST /organizations/:organization_id/memberships/create_with_new_user" do
    it "creates a new user and membership" do
      expect {
        post create_with_new_user_organization_memberships_path(organization), params: {
          membership: {
            email: 'newuser@example.com',
            name: 'New User',
            initials: 'NU',
            role: 'member',
            project_creator: true
          }
        }
      }.to change(User, :count).by(1)
        .and change(Membership, :count).by(1)

      expect(response).to redirect_to(organization_memberships_path(organization))
      expect(flash[:notice]).to eq('Invitation sent successfully.')
    end

    it "fails with invalid params" do
      post create_with_new_user_organization_memberships_path(organization), params: {
        membership: {
          email: 'invalid-email',
          name: '',
          role: 'member'
        }
      }
      expect(response).to render_template(:new_user_form)
    end
  end

  describe "GET /organizations/:organization_id/memberships/:id/edit" do
    it "returns http success" do
      get edit_organization_membership_path(organization, member_membership)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:organization_id/memberships/:id" do
    it "updates the membership" do
      patch organization_membership_path(organization, member_membership), params: {
        membership: {
          role: 'admin',
          project_creator: true
        }
      }
      expect(member_membership.reload.role).to eq('admin')
      expect(response).to redirect_to(organization_memberships_path(organization))
      expect(flash[:notice]).to eq('Member was successfully updated.')
    end

    it "fails with invalid params" do
      patch organization_membership_path(organization, member_membership), params: {
        membership: {
          role: 'invalid_role'
        }
      }
      expect(response).to render_template(:edit)
    end
  end

  describe "DELETE /organizations/:organization_id/memberships/:id" do
    it "destroys the membership" do
      delete organization_membership_path(organization, member_membership)
      expect(Membership.exists?(member_membership.id)).to be_falsey
      expect(response).to redirect_to(organization_memberships_path(organization))
      expect(flash[:notice]).to eq('Member was successfully removed.')
    end
  end

  describe "GET /organizations/:organization_id/memberships/report" do
    it "returns a CSV file" do
      get report_organization_memberships_path(organization, format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to include('text/csv')
      expect(response.headers['Content-Disposition']).to include("memberships-#{Date.today}.csv")
    end
  end
end
