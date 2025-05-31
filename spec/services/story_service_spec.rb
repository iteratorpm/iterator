require 'rails_helper'

RSpec.describe StoryService do
  let(:project) { create(:project, auto_iteration_planning: true) }
  let(:story_attributes) { attributes_for(:story, requester_id: user.id, project_id: project.id) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  # Mock Turbo broadcasting to avoid actual broadcasts in tests
  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to)
  end

  describe '.create' do
    context 'when story saves successfully' do
      it 'returns the story and true' do
        story, success = described_class.create(project, story_attributes)
        expect(success).to be true
        expect(story).to be_persisted
      end

      it 'triggers iteration recalculation if backlog or recalculation needed' do
        allow_any_instance_of(Story).to receive(:backlog?).and_return(true)
        expect(project).to receive(:recalculate_iterations)
        described_class.create(project, story_attributes)
      end

      it 'does not trigger recalculation when auto_iteration_planning is false' do
        project.update(auto_iteration_planning: false)
        expect(project).not_to receive(:recalculate_iterations)
        described_class.create(project, story_attributes)
      end

      it 'uses the explicit recalculate flag if given' do
        expect(project).to receive(:recalculate_iterations)
        described_class.create(project, story_attributes, recalculate: true)
      end

      context 'broadcasting' do
        it 'broadcasts story creation by default' do
          service_instance = instance_double(described_class)
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:broadcast_story_created)

          described_class.create(project, story_attributes)

          expect(service_instance).to have_received(:broadcast_story_created).with(true)
        end

        it 'skips broadcasting when broadcast: false' do
          service_instance = instance_double(described_class)
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:broadcast_story_created)

          described_class.create(project, story_attributes, broadcast: false)

          expect(service_instance).not_to have_received(:broadcast_story_created)
        end

        it 'broadcasts with recalculation flag when recalculation happens' do
          allow_any_instance_of(Story).to receive(:backlog?).and_return(true)
          allow(project).to receive(:recalculate_iterations)

          service_instance = instance_double(described_class)
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:broadcast_story_created)

          described_class.create(project, story_attributes, recalculate: true)

          expect(service_instance).to have_received(:broadcast_story_created).with(true)
        end
      end

      it 'accepts current_user parameter' do
        story, success = described_class.create(project, story_attributes, current_user: user)
        expect(success).to be true
        expect(story).to be_persisted
      end
    end

    context 'when story fails to save' do
      it 'returns false and does not trigger recalculation' do
        bad_attrs = { name: nil }
        story, success = described_class.create(project, bad_attrs)
        expect(success).to be false
        expect(story).not_to be_persisted
      end

      it 'does not broadcast when save fails' do
        bad_attrs = { name: nil }
        expect(Turbo::StreamsChannel).not_to receive(:broadcast_replace_later_to)
        described_class.create(project, bad_attrs)
      end
    end
  end

  describe '#update' do
    let!(:story) { create(:story, project: project) }
    let(:service) { described_class.new(story, user) }

    it 'updates the story with user and recalculates if needed' do
      allow(story).to receive(:update_with_user).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(true)
      allow(story).to receive(:saved_changes).and_return({})
      expect(project).to receive(:recalculate_iterations)

      result = service.update({ name: 'Updated Title' })
      expect(result).to be true
    end

    it 'updates without user when no current_user' do
      service_without_user = described_class.new(story)
      allow(story).to receive(:update).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(false)
      allow(story).to receive(:saved_changes).and_return({})

      result = service_without_user.update({ name: 'Updated Title' })
      expect(result).to be true
    end

    it 'does not recalculate if recalculation not needed' do
      allow(story).to receive(:update_with_user).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(false)
      allow(story).to receive(:saved_changes).and_return({})
      expect(project).not_to receive(:recalculate_iterations)

      service.update({ name: 'No Change' })
    end

    it 'respects the recalculate param' do
      allow(story).to receive(:update_with_user).and_return(true)
      allow(story).to receive(:iteration_recalculation_needed?).and_return(true)
      allow(story).to receive(:saved_changes).and_return({})
      expect(project).not_to receive(:recalculate_iterations)

      service.update({ name: 'Update' }, recalculate: false)
    end

    it 'returns false if update fails' do
      allow(story).to receive(:update_with_user).and_return(false)
      expect(service.update({ name: '' })).to be false
    end

    context 'broadcasting' do
      before do
        allow(story).to receive(:update_with_user).and_return(true)
        allow(story).to receive(:saved_changes).and_return({ 'name' => ['old', 'new'] })
        allow(story).to receive(:owner_ids).and_return([user.id])
        allow(story).to receive(:iteration_recalculation_needed?).and_return(false)
      end

      it 'broadcasts story update by default' do
        expect(service).to receive(:broadcast_story_updated)
        service.update({ name: 'Updated Title' })
      end

      it 'skips broadcasting when broadcast: false' do
        expect(service).not_to receive(:broadcast_story_updated)
        service.update({ name: 'Updated Title' }, broadcast: false)
      end

      it 'captures previous attributes for broadcasting' do
        original_attrs = story.attributes.dup
        original_owner_ids = story.owner_ids.dup

        expect(service).to receive(:broadcast_story_updated).with(
          { 'name' => ['old', 'new'] },
          original_owner_ids,
          false
        )

        service.update({ name: 'Updated Title' })
      end
    end
  end

  describe '#destroy' do
    let!(:story) { create(:story, project: project) }
    let(:service) { described_class.new(story) }

    before do
      allow(story).to receive(:owner_ids).and_return([user.id])
      allow(project).to receive(:membership_ids).and_return([user.id, other_user.id])
      allow(story).to receive(:current_columns).and_return([:backlog])
    end

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

    context 'broadcasting' do
      it 'broadcasts story destruction by default' do
        expect(service).to receive(:broadcast_story_destroyed)
        service.destroy
      end

      it 'skips broadcasting when broadcast: false' do
        expect(service).not_to receive(:broadcast_story_destroyed)
        service.destroy(broadcast: false)
      end

      it 'captures story columns snapshot before destruction' do
        expect(service).to receive(:capture_story_columns_for_all_users).and_call_original
        service.destroy
      end
    end
  end

  describe '#broadcast_story_created' do
    let(:story) { create(:story, project: project) }
    let(:service) { described_class.new(story) }

    context 'when recalculation happened' do
      it 'broadcasts full project update' do
        expect(service).to receive(:broadcast_full_project_update)
        service.broadcast_story_created(true)
      end
    end

    context 'when no recalculation happened' do
      it 'broadcasts only affected story columns' do
        allow(story).to receive(:current_columns_for_all_users).and_return([:backlog])
        expect(service).to receive(:broadcast_story_columns).with([:backlog])
        service.broadcast_story_created(false)
      end
    end
  end

  describe 'private methods' do
    let(:story) { create(:story, project: project) }
    let(:service) { described_class.new(story) }

    describe '#broadcast_full_project_update' do
      before do
        allow(project).to receive_message_chain(:memberships, :find_each).and_yield(double(id: user.id))
      end

      it 'broadcasts updates to all main columns' do
        [:icebox, :backlog, :current, :done].each do |column|
          expect(service).to receive(:broadcast_column_update).with(column)
        end
        expect(service).to receive(:broadcast_column_update).with(:my_work, user.id)

        service.send(:broadcast_full_project_update)
      end
    end

    describe '#broadcast_column_update' do
      it 'broadcasts icebox column update' do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to).with(
          [project, "stories"],
          target: "column-icebox",
          partial: "projects/stories/column",
          locals: {
            project_id: project.id,
            state: :unscheduled,
            column_type: :icebox
          }
        )

        service.send(:broadcast_column_update, :icebox)
      end

      it 'broadcasts backlog column update' do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to).with(
          [project, "stories"],
          target: "column-backlog",
          partial: "projects/iterations/column",
          locals: {
            project_id: project.id,
            iteration_state: :backlog,
            column_type: :backlog
          }
        )

        service.send(:broadcast_column_update, :backlog)
      end

      it 'broadcasts current column update' do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to).with(
          [project, "stories"],
          target: "column-current",
          partial: "projects/iterations/column",
          locals: {
            project_id: project.id,
            iteration_state: :current,
            column_type: :current
          }
        )

        service.send(:broadcast_column_update, :current)
      end

      it 'broadcasts done column update' do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to).with(
          [project, "stories"],
          target: "column-done",
          partial: "projects/iterations/column",
          locals: {
            project_id: project.id,
            iteration_state: :done,
            column_type: :done
          }
        )

        service.send(:broadcast_column_update, :done)
      end

      it 'broadcasts my_work column update with user_id' do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_later_to).with(
          [project, "stories", "user_#{user.id}"],
          target: "column-my-work",
          partial: "projects/stories/column",
          locals: {
            project_id: project.id,
            user_id: user.id,
            column_type: :my_work
          }
        )

        service.send(:broadcast_column_update, :my_work, user.id)
      end
    end

    describe '#capture_story_columns_for_all_users' do
      before do
        allow(story).to receive(:owner_ids).and_return([user.id])
        allow(project).to receive(:membership_ids).and_return([user.id, other_user.id])
        allow(story).to receive(:current_columns).with(user.id).and_return([:backlog])
        allow(story).to receive(:current_columns).with(other_user.id).and_return([:icebox])
      end

      it 'captures columns for all relevant users' do
        result = service.send(:capture_story_columns_for_all_users)

        expect(result).to eq({
          user.id => [:backlog],
          other_user.id => [:icebox]
        })
      end
    end

    describe '#broadcast_specific_columns' do
      it 'broadcasts regular columns without user_id' do
        expect(service).to receive(:broadcast_column_update).with(:backlog)
        expect(service).to receive(:broadcast_column_update).with(:current)

        service.send(:broadcast_specific_columns, [:backlog, :current], [user.id])
      end

      it 'broadcasts my_work columns with user_ids' do
        expect(service).to receive(:broadcast_column_update).with(:my_work, user.id)
        expect(service).to receive(:broadcast_column_update).with(:my_work, other_user.id)

        service.send(:broadcast_specific_columns, [:my_work], [user.id, other_user.id])
      end
    end
  end
end
