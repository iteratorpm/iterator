require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:user) { create(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_length_of(:name).is_at_least(1).is_at_most(50) }
    it { is_expected.to validate_numericality_of(:velocity).is_greater_than_or_equal_to(0) }

    it 'validates time_zone inclusion' do
      expect(project).to validate_inclusion_of(:time_zone)
        .in_array(ActiveSupport::TimeZone.all.map(&:name))
    end

  end

  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:project_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:project_memberships) }
    it { is_expected.to have_many(:integrations).dependent(:destroy) }
    it { is_expected.to have_many(:epics).dependent(:destroy) }
    it { is_expected.to have_many(:labels).dependent(:destroy) }
    it { is_expected.to have_many(:iterations).dependent(:destroy) }
    it { is_expected.to have_many(:stories).dependent(:destroy) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_many(:favorited_by).through(:favorites).source(:user) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_project) { create(:project) }
      let!(:archived_project) { create(:project, :archived) }

      it 'returns only active projects' do
        expect(described_class.active).to eq([active_project])
      end
    end

    describe '.archived' do
      let!(:active_project) { create(:project) }
      let!(:archived_project) { create(:project, :archived) }

      it 'returns only archived projects' do
        expect(described_class.archived).to eq([archived_project])
      end
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:iteration_start_day)
          .with_values(sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6) }
    it { is_expected.to define_enum_for(:point_scale)
          .with_values(linear_0123: 0, fibonacci: 1, powers_of_2: 2, custom: 3) }
    it { is_expected.to define_enum_for(:velocity_strategy)
          .with_values(past_iters_1: 0, past_iters_2: 1, past_iters_3: 2, past_iters_4: 3) }
    it { is_expected.to define_enum_for(:priority_display_scope)
          .with_values(icebox_only: 0, all_panels: 1) }
  end

  describe 'callbacks' do
    let(:project) { create(:project) }

    it 'recalculates iterations when velocity strategy changes' do
      expect(project).to receive(:recalculate_iterations)
      project.update(velocity_strategy: :past_iters_2)
    end

    it 'recalculates iterations when iteration length changes' do
      expect(project).to receive(:recalculate_iterations)
      project.update(iteration_length: 2)
    end

    it 'recalculates iterations when iteration start day changes' do
      expect(project).to receive(:recalculate_iterations)
      project.update(iteration_start_day: :wednesday)
    end
  end

  describe '#plan_current_iteration' do
    let(:project) { create(:project) }

    before do
      travel_to Time.zone.local(2025, 5, 5) # Monday, May 5, 2025

      create(:iteration,
             project: project,
             state: :current,
             start_date: 2.weeks.ago,
             end_date: 1.day.ago)
    end

    after do
      travel_back
    end

    it 'loads new stories into the current iteration' do
      # Create some backlog stories
      create(:story, project: project, state: :unstarted, estimate: 3)
      create(:story, project: project, state: :unstarted, estimate: 2)
      create(:story, project: project, state: :started, estimate: 2)

      project.plan_current_iteration

      # New iteration should have the stories
      current_iteration = project.iterations.current.first
      expect(current_iteration.stories.count).to eq(3)
      expect(current_iteration.stories.sum(:estimate)).to eq(7)
    end

    it 'completes past iterations' do
      past_iteration = create(:iteration, project: project, start_date: 2.weeks.ago, end_date: 1.week.ago)
      project.plan_current_iteration
      expect(past_iteration.reload.state).to eq "done"
    end

    it 'finds or creates current iteration' do
      expect(project).to receive(:find_or_create_current_iteration)
      project.plan_current_iteration
    end

    it 'recalculates iterations' do
      expect(project).to receive(:recalculate_iterations)
      project.plan_current_iteration
    end
  end

  describe '#user_ids' do
    it 'returns array of user ids' do
      user1 = create(:user)
      user2 = create(:user)
      project.add_member(user1)
      project.add_member(user2)
      expect(project.user_ids).to match_array([user1.id, user2.id])
    end
  end

  describe 'role checks' do
    let(:owner) { create(:user) }
    let(:member) { create(:user) }
    let(:viewer) { create(:user) }

    before do
      project.add_member(owner, :owner)
      project.add_member(member, :member)
      project.add_member(viewer, :viewer)
    end

    describe '#owner?' do
      it 'returns true for owner' do
        expect(project.owner?(owner)).to be true
      end

      it 'returns false for non-owner' do
        expect(project.owner?(member)).to be false
      end
    end

    describe '#member?' do
      it 'returns true for member' do
        expect(project.member?(member)).to be true
      end

      it 'returns false for non-member' do
        non_member = create(:user)
        expect(project.member?(non_member)).to be false
      end
    end

    describe '#viewer?' do
      it 'returns true for viewer' do
        expect(project.viewer?(viewer)).to be true
      end

      it 'returns false for non-viewer' do
        expect(project.viewer?(member)).to be false
      end
    end
  end

  describe '#add_member' do
    it 'adds a member with default role' do
      expect {
        project.add_member(user)
      }.to change(project.project_memberships, :count).by(1)
      expect(project.project_memberships.last.role).to eq('member')
    end

    it 'adds a member with specified role' do
      expect {
        project.add_member(user, :owner)
      }.to change(project.project_memberships, :count).by(1)
      expect(project.project_memberships.last.role).to eq('owner')
    end
  end

  describe '#current_iteration_points' do
    context 'with current iteration' do
      let!(:story) { create(:story, :accepted, iteration: iteration, estimate: 5) }
      let!(:iteration) { create(:iteration, project: project) }

      it 'returns points from current iteration' do
        allow(project).to receive(:find_or_create_current_iteration).and_return(iteration)
        expect(project.current_iteration_points).to eq(5)
      end
    end

    context 'without current iteration' do
      it 'returns 0' do
        expect(project.current_iteration_points).to eq(0)
      end
    end
  end

  describe '#last_5_iterations' do
    before do
      6.times do |i|
        create(:iteration, project: project, start_date: i.weeks.ago, state: :done)
      end
    end

    it 'returns last 5 completed iterations' do
      expect(project.last_5_iterations.count).to eq(5)
    end

    it 'orders by start_date descending' do
      expect(project.last_5_iterations.first.start_date).to be > project.last_5_iterations.last.start_date
    end
  end

  describe '#calculate_velocity_data' do
    before do
      create(:iteration, project: project, start_date: 1.week.ago, points_completed: 10, state: :done)
      create(:iteration, project: project, start_date: 2.weeks.ago, points_completed: 20, state: :done)
    end

    it 'returns velocity data structure' do
      data = project.calculate_velocity_data
      expect(data[:current_points]).to eq(0)
      expect(data[:average_velocity]).to be_a(Numeric)
      expect(data[:iterations].size).to eq(2)
      expect(data[:iterations].first[:points]).to eq(10)
    end
  end

  describe '#calculate_stories_data' do
    before do
      iteration = create(:iteration, project: project, start_date: 1.week.ago, state: :done)
      create(:story, project: project, iteration: iteration, story_type: 'feature', state: 'accepted')
      create(:story, project: project, iteration: iteration, story_type: 'bug', state: 'accepted')
    end

    it 'returns stories data structure' do
      data = project.calculate_stories_data
      expect(data[:total]).to eq(2)
      expect(data[:by_type]['Feature']).to eq(1)
      expect(data[:iterations].first[:features]).to eq(1)
    end
  end

  describe '#average_velocity' do
    before do
      create(:iteration, project: project, points_completed: 10, state: :done)
      create(:iteration, project: project, points_completed: 20, state: :done)
    end

    it 'returns average of completed iterations' do
      expect(project.average_velocity).to eq(15.0)
    end
  end

  describe '#volatility' do
    context 'with less than 2 iterations' do
      it 'returns 0%' do
        expect(project.volatility).to eq('0%')
      end
    end

    context 'with multiple iterations zero points completed' do
      before do
        create(:iteration, project: project, points_completed: 0, state: :done)
        create(:iteration, project: project, points_completed: 0, state: :done)
      end

      it 'returns volatility percentage' do
        expect(project.volatility).to eq('0%')
      end
    end

    context 'with multiple iterations' do
      before do
        create(:iteration, project: project, points_completed: 10, state: :done)
        create(:iteration, project: project, points_completed: 20, state: :done)
      end

      it 'returns volatility percentage' do
        expect(project.volatility).to match(/\d+%/)
      end
    end
  end
end
