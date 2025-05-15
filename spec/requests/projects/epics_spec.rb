require 'rails_helper'

RSpec.describe "Projects::Epics", type: :request do
  let(:project) { create(:project, :with_members) }
  let(:user) { project.memberships.first.user }
  let(:epic) { create(:epic, project: project) }
  let(:valid_attributes) { attributes_for(:epic, position: :first) }
  let(:invalid_attributes) { attributes_for(:epic, name: '') }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders a successful response" do
      get project_epics_path(project)
      expect(response).to be_successful
    end

    it "assigns ranked epics with includes" do
      epic # create the epic
      get project_epics_path(project)
      expect(assigns(:epics)).to eq([epic])
      expect(assigns(:panel_id)).to eq("epics_panel")
    end
  end

  describe.skip "GET /show" do
    it "renders a successful response" do
      get project_epic_path(project, epic)
      expect(response).to be_successful
    end

    context "when unauthorized" do
      before do
        sign_in create(:user) # different user
      end

      it "raises authorization error" do
        expect {
          get project_epic_path(project, epic)
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe.skip "GET /new" do
    it "renders a successful response" do
      get new_project_epic_path(project)
      expect(response).to be_successful
    end

    it "initializes a new epic" do
      get new_project_epic_path(project)
      expect(assigns(:epic)).to be_a_new(Epic)
    end
  end

  describe.skip "GET /edit" do
    it "renders a successful response" do
      get edit_project_epic_path(project, epic)
      expect(response).to be_successful
    end

    context "when unauthorized" do
      before do
        sign_in create(:user) # different user
      end

      it "raises authorization error" do
        expect {
          get edit_project_epic_path(project, epic)
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Epic" do
        expect {
          post project_epics_path(project), params: { epic: valid_attributes }
        }.to change(Epic, :count).by(1)
      end

      it "redirects to HTML with notice" do
        post project_epics_path(project), params: { epic: valid_attributes }
        expect(response).to redirect_to(project_epics_path(project))
        expect(flash[:notice]).to eq('Epic was successfully created.')
      end

      it "responds with Turbo Stream" do
        post project_epics_path(project), params: { epic: valid_attributes }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"prepend\" target=\"column-epics\"")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Epic" do
        expect {
          post project_epics_path(project), params: { epic: invalid_attributes }
        }.not_to change(Epic, :count)
      end

      it "renders Turbo Stream validation errors" do
        post project_epics_path(project), params: { epic: invalid_attributes }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response.media_type).to eq Mime[:html]
      end

    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { attributes_for(:epic) }

      it "updates the requested epic" do
        patch project_epic_path(project, epic), params: { epic: new_attributes }
        epic.reload
        expect(epic.name).to eq(new_attributes[:name])
      end

      it "redirects to HTML with notice" do
        patch project_epic_path(project, epic), params: { epic: new_attributes }
        expect(response).to redirect_to(project_epics_path(project))
        expect(flash[:notice]).to eq('Epic was successfully updated.')
      end

      it "responds with Turbo Stream" do
        patch project_epic_path(project, epic), params: { epic: new_attributes }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"replace\" target=\"epic_#{epic.id}\"")
      end
    end

    context "with invalid parameters" do
      it "renders Turbo Stream validation errors" do
        patch project_epic_path(project, epic), params: { epic: invalid_attributes }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response.media_type).to eq Mime[:html]
      end

    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested epic" do
      epic # create the epic
      expect {
        delete project_epic_path(project, epic)
      }.to change(Epic, :count).by(-1)
    end

    it "responds with Turbo Stream" do
      delete project_epic_path(project, epic), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("turbo-stream action=\"remove\" target=\"epic_#{epic.id}\"")
    end

    it "redirects to HTML with notice" do
      delete project_epic_path(project, epic)
      expect(response).to redirect_to(project_epics_path(project))
      expect(flash[:notice]).to eq('Epic was successfully deleted.')
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Epic).to receive(:destroy).and_return(false)
      end

      it "redirects with alert" do
        delete project_epic_path(project, epic)
        expect(response).to redirect_to(project_epics_path(project))
        expect(flash[:alert]).to eq('Failed to delete epic.')
      end
    end
  end
end
