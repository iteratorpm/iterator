require 'rails_helper'

RSpec.describe Story, type: :model do
  # Add to existing Story spec file
  describe 'callbacks' do
    let(:project) { create(:project) }
    let!(:story) { create(:story, project: project, state: :unstarted, estimate: 3) }

    it 'triggers iteration recalculation when estimate changes' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Change estimate
      story.update(estimate: 5)
    end

    it 'triggers iteration recalculation when state changes to backlog' do
      # Start with a story in icebox
      story.update(state: :unscheduled)

      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Move to backlog
      story.update(state: :unstarted)
    end

    it 'triggers iteration recalculation when state changes to current' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Move to started
      story.update(state: :started)
    end

    it 'triggers iteration recalculation when story is discarded' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Discard story
      story.discard
    end

    it 'triggers iteration recalculation when story is created in backlog' do
      # Mocked expectation
      expect_any_instance_of(Project).to receive(:recalculate_iterations)

      # Create a new story in backlog
      create(:story, project: project, state: :unstarted, estimate: 2)
    end
  end
end

