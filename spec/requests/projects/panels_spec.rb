require 'rails_helper'

RSpec.describe "Projects::Panels", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, :current_iteration, :with_members) }
  let(:member) { project.users.first }

  before do
    sign_in member
  end

  describe "GET /show" do
    context "when accessing different panel types" do
      before do
        # Create test data
        create_list(:story, 3, :accepted, :estimated, project: project,
                   iteration: create(:iteration, :past, project: project))
        create_list(:story, 2, :current, :estimated, project: project, iteration: project.iterations.current.first)
        create_list(:story, 2, :backlog, :estimated, project: project)
        create_list(:story, 2, :icebox, project: project)
      end

      it "returns success for done panel" do
        get done_panel_project_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Done")
      end

      it "returns success for current panel" do
        get current_panel_project_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Current Iteration")
      end

      it "returns success for current_backlog panel" do
        get current_backlog_panel_project_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Current Iteration/Backlog")
      end

      it "returns success for backlog panel" do
        get backlog_panel_project_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Backlog")
      end

      it "returns success for icebox panel" do
        get icebox_panel_project_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Icebox")
      end

      it "returns JSON format for current panel" do
        get icebox_panel_project_path(project), headers: { "ACCEPT" => "application/json" }
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['panel']).to eq('icebox_panel')
        expect(json['stories'].size).to eq(2)
      end
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "raises authorization error" do
        get current_panel_project_path(project)
        expect(response).to have_http_status(:not_found)
      end
    end

  end
end
