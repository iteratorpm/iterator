require 'rails_helper'

RSpec.describe "Projects::Panels", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, :with_members) }
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
        create_list(:story, 2, :current, :estimated, project: project)
        create_list(:story, 2, :backlog, :estimated, project: project)
        create_list(:story, 2, :icebox, project: project)
      end

      it "returns success for done panel" do
        get project_panel_path(project, panel: 'done')
        expect(response).to be_successful
        expect(response.body).to include("Done")
      end

      it "returns success for current panel" do
        get project_panel_path(project, panel: 'current')
        expect(response).to be_successful
        expect(response.body).to include("Current Iteration")
      end

      it "returns success for current_backlog panel" do
        get project_panel_path(project, panel: 'current_backlog')
        expect(response).to be_successful
        expect(response.body).to include("Current Iteration/Backlog")
      end

      it "returns success for backlog panel" do
        get project_panel_path(project, panel: 'backlog')
        expect(response).to be_successful
        expect(response.body).to include("Backlog")
      end

      it "returns success for icebox panel" do
        get project_panel_path(project, panel: 'icebox')
        expect(response).to be_successful
        expect(response.body).to include("Icebox")
      end

      it "returns JSON format for current panel" do
        get project_panel_path(project, panel: 'current'), headers: { "ACCEPT" => "application/json" }
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['panel']['title']).to eq('Current Iteration')
        expect(json['stories'].size).to eq(2)
      end
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "raises authorization error" do
        expect {
          get project_panel_path(project, panel: 'current')
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "with done panel specific behavior" do
      let!(:old_iteration) { create(:iteration, :past, project: project, start_date: 3.weeks.ago) }
      let!(:recent_iteration) { create(:iteration, :past, project: project, start_date: 1.week.ago) }
      let!(:old_stories) { create_list(:story, 2, :accepted, project: project, iteration: old_iteration) }
      let!(:recent_stories) { create_list(:story, 2, :accepted, project: project, iteration: recent_iteration) }

      it "shows done stories grouped by iteration in chronological order" do
        get project_panel_path(project, panel: 'done')
        expect(response.body).to match(/Iteration #{old_iteration.number}.*Iteration #{recent_iteration.number}/m)
      end
    end

    context "with current panel specific behavior" do
      let!(:current_iteration) { create(:iteration, :current, project: project, velocity: 8) }
      let!(:current_stories) { create_list(:story, 3, :current, :estimated, project: project, estimate: 3) }

      it "shows point total vs velocity" do
        get project_panel_path(project, panel: 'current')
        expect(response.body).to include("9/8") # 3 stories * 3 points = 9 vs velocity 8
      end
    end
  end
end
