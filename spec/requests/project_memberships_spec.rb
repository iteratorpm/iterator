require 'rails_helper'

RSpec.describe "ProjectMemberships", type: :request do
  let(:organization) { create(:organization) }

  let(:owner)   { create(:user) }
  let(:member)  { create(:user) }
  let(:viewer)  { create(:user) }
  let(:invitee) { create(:user) }

  let(:project) { create(:project, organization: organization) }

  let!(:owner_membership)  { create(:project_membership, project: project, user: owner, role: :owner) }
  let!(:member_membership) { create(:project_membership, project: project, user: member, role: :member) }
  let!(:viewer_membership) { create(:project_membership, project: project, user: viewer, role: :viewer) }

  describe "GET /projects/:project_id/memberships" do
    context "as an owner" do
      before { sign_in owner }

      it "returns success" do
        get project_memberships_path(project)
        expect(response).to have_http_status(:success)
      end
    end

    context "as a viewer" do
      before { sign_in viewer }

      it "returns success (can view)" do
        get project_memberships_path(project)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /projects/:project_id/memberships" do
    let(:email) { "newuser@example.com" }

    context "as an owner" do
      before { sign_in owner }

      it "invites a new user" do
        expect {
          post project_memberships_path(project), params: {
            project_membership: {
              emails: email,
              role: "member"
            }
          }
        }.to change(User, :count).by(1)
          .and change(ProjectMembership, :count).by(1)

        expect(response).to redirect_to(project_memberships_path(project))
        follow_redirect!
        expect(response.body).to include("Invitations sent successfully.")
      end
    end

    context "as a member" do
      before { sign_in member }

      it "is unauthorized to invite" do
        post project_memberships_path(project), params: {
          project_membership: { emails: email, role: "viewer" }
        }

        expect(response).to be_access_denied
      end
    end
  end

  describe "PUT /memberships/:id/resend_invitation" do
    let(:pending_user) { User.invite!(username: "t", name: "t", email: "pending@example.com", invited_by: owner) }
    let!(:pending_membership) { create(:project_membership, project: project, user: pending_user, role: :member) }

    context "as an owner" do
      before { sign_in owner }

      it "resends an invitation" do
        put resend_invitation_membership_path(pending_membership)

        expect(response).to redirect_to(project_memberships_path(project))
        follow_redirect!
        expect(response.body).to include("Invitation resent successfully.")
      end
    end

    context "when user has already accepted" do
      before do
        pending_user.accept_invitation!
        sign_in owner
      end

      it "does not resend invitation" do
        put resend_invitation_membership_path(pending_membership)
        follow_redirect!

        expect(response.body).to include("User has already accepted the invitation.")
      end
    end
  end

  describe "PATCH /memberships/:id" do
    before { sign_in owner }

    it "updates a membership role" do
      patch membership_path(member_membership), params: {
        project_membership: { role: "viewer" }
      }

      expect(response).to redirect_to(project_memberships_path(project))
      follow_redirect!
      expect(response.body).to include("Role updated successfully.")
      expect(member_membership.reload.role).to eq("viewer")
    end
  end

  describe "DELETE /memberships/:id" do
    context "as an owner" do
      before { sign_in owner }

      it "removes a member" do
        expect {
          delete membership_path(member_membership)
        }.to change(ProjectMembership, :count).by(-1)

        expect(response).to redirect_to(project_memberships_path(project))
        follow_redirect!
        expect(response.body).to include("Member removed successfully.")
      end
    end

    context "as a viewer" do
      before { sign_in viewer }

      it "is forbidden" do
        delete membership_path(owner_membership)
        expect(response).to be_access_denied
      end
    end
  end

  describe "GET /projects/:project_id/memberships/search_users" do
    before { sign_in owner }

    it "returns matching users not in project" do
      extra_user = create(:user, name: "Tina Search", email: "search@example.com")
      create(:membership, user: extra_user, organization: organization)

      get search_users_project_memberships_path(project), params: { term: "search" }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).first["email"]).to eq("search@example.com")
    end
  end
end
