require 'rails_helper'

RSpec.describe "Projects::Iterations", type: :request do
  let(:project) { create(:project, :with_members) }
  let(:user) { project.project_memberships.first.user }
  let(:iteration) { create(:iteration, project: project) }

  before do
    sign_in user
  end

  describe "GET /done" do
    context "when there are done iterations" do
      before do
        create_list(:iteration, 2, :done, project: project).each do |iteration|
          create_list(:story, 3, iteration: iteration, project: project)
        end
      end

      it "returns success and shows done iterations" do
        get done_project_iterations_path(project)
        expect(response).to be_successful
        expect(assigns(:iterations).count).to eq(2)
        expect(assigns(:iterations)).to all(have_attributes(state: 'done'))
      end
    end
  end

  describe "GET /current" do
    context "when current iteration exists" do
      before do
        create(:iteration, :current, project: project)
      end

      it "returns the current iteration" do
        get current_project_iterations_path(project)
        expect(response).to be_successful
        expect(assigns(:current_iteration)).to be_present
      end
    end

    context "when current iteration doesn't exist" do
      it "creates and returns a new current iteration" do
        expect {
          get current_project_iterations_path(project)
        }.to change { project.iterations.count }.by(1)
        expect(response).to be_successful
        expect(assigns(:current_iteration)).to be_present
      end
    end
  end

  describe "GET /current_backlog" do
    before do
      create(:iteration, :current, project: project)
      create_list(:iteration, 3, :backlog, project: project).each do |iteration|
        create_list(:story, 2, iteration: iteration, project: project)
      end
    end

    it "returns current iteration and backlog iterations" do
      get current_backlog_project_iterations_path(project)
      expect(response).to be_successful
      expect(assigns(:current_iteration)).to be_present
      expect(assigns(:backlog_iterations).count).to eq(3)
    end
  end

  describe "GET /backlog" do
    before do
      create_list(:iteration, 4, :backlog, project: project).each do |iteration|
        create_list(:story, 3, iteration: iteration, project: project)
      end
    end

    it "returns all backlog iterations" do
      get backlog_project_iterations_path(project)
      expect(response).to be_successful
      expect(assigns(:iterations).count).to eq(4)
      expect(assigns(:iterations)).to all(have_attributes(state: 'backlog'))
    end
  end

  describe.skip "PATCH /update" do
    let(:iteration) { create(:iteration, project: project) }

    it "updates team strength and recalculates velocity" do
      expect(project).to receive(:recalculate_iterations)
      patch project_iteration_path(project, iteration), params: { team_strength: 5 }
      expect(response).to be_successful
      expect(iteration.reload.team_strength).to eq(5)
    end
  end
end
