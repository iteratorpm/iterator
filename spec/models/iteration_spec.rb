require 'rails_helper'

RSpec.describe Iteration, type: :model do
  let(:project) { create(:project, time_zone: 'Eastern Time (US & Canada)', automatic_planning: true) }
  let(:now) { Time.current.in_time_zone(project.time_zone) }

  describe 'validations' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:number) }
    it { should validate_numericality_of(:number).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:velocity).is_greater_than_or_equal_to(0) }

    it 'validates end_date is after start_date' do
      iteration = build(:iteration, start_date: now, end_date: now - 1.day)
      expect(iteration).not_to be_valid
      expect(iteration.errors[:end_date]).to include('must be after start date')
    end
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should have_many(:stories).dependent(:nullify) }
  end

  describe 'scopes' do
    let!(:past_iteration) { create(:iteration, :done, project: project) }
    let!(:current_iteration) { create(:iteration, :current, project: project) }
    let!(:future_iteration) { create(:iteration, :backlog, project: project) }

    describe '.current' do
      it 'returns iterations marked as current' do
        expect(project.iterations.current).to eq([current_iteration])
      end
    end

    describe '.backlog' do
      it 'returns future iterations ordered by start_date' do
        expect(project.iterations.backlog).to eq([future_iteration])
      end
    end

    describe '.done' do
      it 'returns past iterations ordered by start_date desc' do
        expect(project.iterations.done).to eq([past_iteration])
      end
    end

    describe '.for_date' do
      it 'returns iterations for a specific date' do
        date = current_iteration.start_date + 1.day
        expect(project.iterations.for_date(date)).to eq([current_iteration])
      end
    end
  end

  describe '.find_or_create_current_iteration' do
    context 'when current iteration exists' do
      let!(:current_iteration) { create(:iteration, :current, project: project) }

      it 'returns the existing current iteration' do
        expect(Iteration.find_or_create_current_iteration(project)).to eq(current_iteration)
      end
    end

    context 'when no current iteration exists but one includes today' do
      let!(:active_iteration) { create(:iteration, project: project, start_date: now - 1.day, end_date: now + 5.days) }

      it 'returns the iteration that includes today' do
        expect(Iteration.find_or_create_current_iteration(project)).to eq(active_iteration)
      end
    end

    context 'when no relevant iteration exists' do
      it 'creates a new current iteration' do
        expect {
          Iteration.find_or_create_current_iteration(project)
        }.to change { project.iterations.count }.by(1)
      end

      it 'returns the newly created iteration' do
        iteration = Iteration.find_or_create_current_iteration(project)
        expect(iteration).to be_persisted
        expect(iteration.current?).to be true
      end
    end

    context 'with time zone considerations' do
      let(:tokyo_project) { create(:project, time_zone: 'Tokyo') }
      let(:tokyo_now) { Time.current.in_time_zone(tokyo_project.time_zone) }

      it 'respects project time zone when finding iterations' do
        # Create iteration that's current in Tokyo time but not in UTC
        iteration = create(:iteration, project: tokyo_project,
                           start_date: tokyo_now.to_date - 1.day,
                           end_date: tokyo_now.to_date + 5.days)

        # Test at a time when it's different dates in different zones
        Time.use_zone('UTC') do
          test_time = tokyo_now.end_of_day - 1.hour # Still same date in Tokyo, but previous date in UTC
          travel_to(test_time) do
            expect(Iteration.find_or_create_current_iteration(tokyo_project)).to eq(iteration)
          end
        end
      end
    end
  end

  describe '#full?' do
    let(:iteration) { create(:iteration, project: project, velocity: 10) }

    it 'returns false when no velocity set' do
      iteration.update(velocity: nil)
      expect(iteration.full?).to be false
    end

    it 'returns false when total points < velocity' do
      create(:story, iteration: iteration, estimate: 5)
      expect(iteration.full?).to be false
    end

    it 'returns true when total points >= velocity' do
      create_list(:story, 2, iteration: iteration, estimate: 5)
      expect(iteration.full?).to be true
    end
  end

  describe '#complete!' do
    let(:iteration) { create(:iteration, project: project, start_date: now.to_date - 1.week, end_date: now.to_date - 1.day) }
    let!(:accepted_story) { create(:story, :accepted, iteration: iteration) }
    let!(:started_story) { create(:story, :started, iteration: iteration) }

    it 'nils iteration for unaccepted stories' do
      iteration.complete!
      expect(started_story.reload.state).to eq('started')
      expect(started_story.iteration).to be_nil

      expect(accepted_story.iteration.id).to eq iteration.id
    end

    it 'marks iteration as not current' do
      iteration.update(state: :current)
      iteration.complete!
      expect(iteration.reload.current?).to be false
    end

  end

  describe 'time zone sensitive methods' do
    let(:iteration) { create(:iteration, project: project, start_date: now.to_date, end_date: now.to_date + 6.days) }

    describe '#to_s' do
      it 'formats dates in project time zone' do
        expected_format = "Iteration ##{iteration.number}: #{now.strftime('%b %d')} - #{(now + 6.days).strftime('%b %d')}"
        expect(iteration.to_s).to eq(expected_format)
      end
    end
  end

  describe '#shift!' do
    let(:iteration) { create(:iteration, project: project, start_date: now.to_date, end_date: now.to_date + 6.days) }

    it 'shifts iteration dates by specified weeks' do
        iteration.shift!(weeks: 1)

        expect(iteration.start_date).to eq(now.to_date + 1.weeks)
        expect(iteration.end_date).to eq(now.to_date + 6.days + 1.weeks)
    end
  end

  describe 'point calculations' do
    let(:iteration) { create(:iteration, project: project) }
    let!(:accepted_story) { create(:story, :accepted, iteration: iteration, estimate: 3) }
    let!(:started_story) { create(:story, :started, iteration: iteration, estimate: 2) }
    let!(:rejected_story) { create(:story, :rejected, iteration: iteration, estimate: 1) }

    describe '#points_accepted' do
      it 'returns sum of accepted story points' do
        expect(iteration.points_accepted).to eq(3)
      end
    end

    describe '#points_remaining' do
      it 'returns difference between total and completed points' do
        expect(iteration.points_remaining).to eq(3) # (3+2+1) - 3
      end
    end

    describe '#completion_percentage' do
      it 'returns percentage of completed points' do
        expect(iteration.completion_percentage).to eq(50) # 3/6 * 100
      end

      it 'returns -1 when no points' do
        iteration.stories.update_all(estimate: -1)
        expect(iteration.completion_percentage).to eq(0)
      end
    end

    describe '#rejection_rate' do
      it 'returns percentage of rejected stories' do
        expect(iteration.rejection_rate).to eq(50.0) # 1 rejected out of 2 completed (accepted + rejected)
      end
    end
  end

  describe 'callbacks' do
    let(:project) { create(:project) }
    let(:iteration) { create(:iteration, project: project) }

    it 'triggers recalculation when team strength changes' do
      # Mocked expectation
      expect(project).to receive(:recalculate_iterations)

      # Change team strength
      iteration.update(team_strength: 80)
    end
  end
end
