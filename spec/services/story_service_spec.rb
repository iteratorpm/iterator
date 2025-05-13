require 'rails_helper'

RSpec.describe StoryService do
  let(:project) { create(:project, auto_iteration_planning: true) }
  let(:story_attributes) { attributes_for(:story, {requester_id: user.id, project_id: project.id}) }
  let(:user) { create(:user) }

  describe '.create' do
    context 'when story saves successfully' do
      it 'returns the story and true' do
        story, success = described_class.create(project, Story.new(story_attributes))
        expect(success).to be true
        expect(story).to be_persisted
      end

      it 'triggers iteration recalculation if backlog or recalculation needed' do
        allow_any_instance_of(Story).to receive(:backlog?).and_return(true)
        expect(project).to receive(:recalculate_iterations)

        described_class.create(project, Story.new(story_attributes))
      end

      it 'does not trigger recalculation when auto_iteration_planning is false' do
        project.update(auto_iteration_planning: false)
        expect(project).not_to receive(:recalculate_iterations)

        described_class.create(project, Story.new(story_attributes))
      end

      it 'uses the explicit recalculate flag if given' do
        expect(project).to receive(:recalculate_iterations)
        described_class.create(project, Story.new(story_attributes), recalculate: true)
      end
    end

    context 'when story fails to save' do
      it 'returns false and does not trigger recalculation' do
        bad_attrs = { name: nil }
        story, success = described_class.create(project, Story.new(bad_attrs))

        expect(success).to be false
        expect(story).not_to be_persisted
      end
    end
  end

  describe '#update' do
    let!(:story) { create(:story, project: project) }
    let(:service) { described_class.new(story, user) }

    it 'updates the story with user and recalculates if needed' do
      allow(story).to receive(:update_with_user).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(true)
      expect(project).to receive(:recalculate_iterations)

      service.update({ name: 'Updated Title' })
    end

    it 'does not recalculate if recalculation not needed' do
      allow(story).to receive(:update_with_user).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(false)
      expect(project).not_to receive(:recalculate_iterations)

      service.update({ name: 'No Change' })
    end

    it 'respects the recalculate param' do
      allow(story).to receive(:update_with_user).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(true)

      expect(project).not_to receive(:recalculate_iterations)
      service.update({ name: 'Update' }, recalculate: false)
    end

    it 'returns false if update fails' do
      allow(story).to receive(:update_with_user).and_return(false)
      expect(service.update({ name: '' })).to be false
    end
  end

  describe '#destroy' do
    let!(:story) { create(:story, project: project) }
    let(:service) { described_class.new(story) }

    it 'destroys the story and recalculates if needed' do
      expect(project).to receive(:recalculate_iterations)
      expect(service.destroy).to be_truthy
    end

    it 'respects the recalculate param' do
      expect(project).not_to receive(:recalculate_iterations)
      service.destroy(recalculate: false)
    end

    it 'does not recalculate if destroy fails' do
      allow(story).to receive(:destroy).and_return(false)
      expect(project).not_to receive(:recalculate_iterations)
      expect(service.destroy).to be false
    end
  end
end
