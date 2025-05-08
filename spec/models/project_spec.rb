require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { create(:project, time_zone: 'UTC', iteration_start_day: 'monday') }

  describe 'callbacks' do
    let(:project) { create(:project) }

    it 'recalculates iterations when velocity strategy changes' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Change velocity strategy
      project.update(velocity_strategy: :past_iters_3)
    end

    it 'recalculates iterations when iteration length changes' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Change iteration length
      project.update(iteration_length: 2)
    end

    it 'recalculates iterations when iteration start day changes' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Change start day
      project.update(iteration_start_day: :wednesday)
    end
  end
end
