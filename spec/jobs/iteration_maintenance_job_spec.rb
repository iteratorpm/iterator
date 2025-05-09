require 'rails_helper'

RSpec.describe IterationMaintenanceJob, type: :job do
  describe '#perform' do
    let!(:active_project1) { create(:project, archived: false) }
    let!(:active_project2) { create(:project, archived: false) }
    let!(:archived_project) { create(:project, archived: true) }

    before do
      travel_to Time.zone.local(2025, 5, 5) # Monday, May 5, 2025

      # Create iterations that are about to be completed
      create(:iteration,
             project: active_project1,
             state: :current,
             start_date: 2.weeks.ago,
             end_date: 1.day.ago)

      create(:iteration,
             project: active_project2,
             state: :current,
             start_date: 1.week.ago,
             end_date: 1.day.ago)
    end

    after do
      travel_back
    end

    it 'completes expired iterations and creates new ones' do
      # Allow the original methods to execute
      allow(active_project1).to receive(:plan_current_iteration).and_call_original
      allow(active_project2).to receive(:plan_current_iteration).and_call_original

      # Run the job
      IterationMaintenanceJob.new.perform

      # Check active_project1
      expect(active_project1.iterations.done.count).to eq(1)
      expect(active_project1.iterations.current.count).to eq(1)

      # Check active_project2
      expect(active_project2.iterations.done.count).to eq(1)
      expect(active_project2.iterations.current.count).to eq(1)
    end

    it 'loads new stories into the current iteration' do
      # Create some backlog stories
      create(:story, project: active_project1, state: :unstarted, estimate: 3)
      create(:story, project: active_project1, state: :unstarted, estimate: 2)

      # Run the job
      IterationMaintenanceJob.new.perform

      # New iteration should have the stories
      current_iteration = active_project1.iterations.current.first
      expect(current_iteration.stories.count).to eq(2)
      expect(current_iteration.stories.sum(:estimate)).to eq(5)
    end

    it 'handles a project with no iterations properly' do
      # Create a new project with no iterations
      new_project = create(:project, archived: false)

      # Run the job
      IterationMaintenanceJob.new.perform

      # Should have created a current iteration
      expect(new_project.iterations.current.count).to eq(1)
    end
  end
end
