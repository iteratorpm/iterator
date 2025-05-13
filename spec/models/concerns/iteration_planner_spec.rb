require 'rails_helper'

RSpec.describe IterationPlanner do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:project) do
    create(:project,
           organization: organization,
           iteration_length: 1,
           time_zone: "UTC",
           velocity_strategy: :past_iters_2,
           iteration_start_day: :monday,
           velocity: 10)
  end

  before do
    # Create project membership
    create(:project_membership, project: project, user: user, role: :owner)
    # Freeze time to a Monday for consistent testing
    travel_to Time.zone.local(2025, 5, 5) # Monday, May 5, 2025
  end

  after do
    travel_back
  end

  describe '.recalculate_all_iterations' do
    it 'recalculates project velocity based on historical data' do
      # Create completed iterations with different point values
      create(:iteration,
             project: project,
             state: :done,
             start_date: 3.weeks.ago,
             end_date: 2.weeks.ago,
             number: 1,
             points_completed: 8)

      create(:iteration,
             project: project,
             state: :done,
             start_date: 2.weeks.ago,
             end_date: 1.week.ago,
             number: 2,
             points_completed: 12)

      # Initial velocity is 10
      expect(project.velocity).to eq(10)

      # Recalculate iterations
      IterationPlanner.recalculate_all_iterations(project)

      # Expect velocity to be the average (8 + 12)/2 = 10
      expect(project.reload.velocity).to eq(10)
    end

    it 'creates a current iteration if one does not exist' do
      expect(project.iterations.current).to be_empty

      IterationPlanner.recalculate_all_iterations(project)

      # Expect a current iteration to be created
      expect(project.iterations.current.count).to eq(1)

      current_iteration = project.iterations.current.first
      expect(current_iteration.start_date).to eq(Date.new(2025, 5, 5)) # Monday
      expect(current_iteration.end_date).to eq(Date.new(2025, 5, 11)) # Sunday
    end

    it 'removes existing backlog iterations and replans them' do
      # Create a current iteration
      current_iteration = create(:iteration,
                                project: project,
                                state: :current,
                                start_date: Date.new(2025, 5, 5),
                                end_date: Date.new(2025, 5, 11),
                                number: 1,
                                velocity: 10)

      # Create some backlog iterations
      create(:iteration,
             project: project,
             state: :backlog,
             start_date: Date.new(2025, 5, 12),
             end_date: Date.new(2025, 5, 18),
             number: 2,
             velocity: 10)

      create(:iteration,
             project: project,
             state: :backlog,
             start_date: Date.new(2025, 5, 19),
             end_date: Date.new(2025, 5, 25),
             number: 3,
             velocity: 10)

      # Before recalculation
      expect(project.iterations.reload.backlog.count).to eq(2)

      # Create some stories
      create_list(:story, 3,
                  project: project,
                  state: :unstarted,
                  estimate: 5,
                  iteration: nil)

      create_list(:story, 1,
                  project: project,
                  state: :unstarted,
                  estimate: 5,
                  iteration: current_iteration)

      # Recalculate
      IterationPlanner.recalculate_all_iterations(project)

      expect(project.iterations.current.first.stories.count).to eq(2)

      # After recalculation
      expect(project.iterations.backlog.count).to eq(1) # Only need 1 iteration for 9 points
      expect(project.iterations.backlog.first.number).to eq(2)
      expect(project.iterations.backlog.first.stories.count).to eq(2)
    end
  end

  describe '.calculate_project_velocity' do
    context 'with no completed iterations' do
      it 'returns the initial velocity' do
        project.update(initial_velocity: 12)
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(12)
      end

      it 'returns 10 if no initial velocity is set' do
        project.update(initial_velocity: nil)
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(10)
      end
    end

    context 'with completed iterations' do
      it 'calculates velocity based on velocity_strategy' do
        # Create completed iterations with different point values
        create(:iteration,
               project: project,
               state: :done,
               start_date: 4.weeks.ago,
               end_date: 3.weeks.ago,
               number: 1,
               points_completed: 6)

        create(:iteration,
               project: project,
               state: :done,
               start_date: 3.weeks.ago,
               end_date: 2.weeks.ago,
               number: 2,
               points_completed: 8)

        create(:iteration,
               project: project,
               state: :done,
               start_date: 2.weeks.ago,
               end_date: 1.week.ago,
               number: 3,
               points_completed: 10)

        create(:iteration,
               project: project,
               state: :done,
               start_date: 1.week.ago,
               end_date: Date.yesterday,
               number: 4,
               points_completed: 12)

        # Test different velocity strategies
        project.update(velocity_strategy: :past_iters_1)
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(12)

        project.update(velocity_strategy: :past_iters_2)
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(11) # (10+12)/2

        project.update(velocity_strategy: :past_iters_3)
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(10) # (8+10+12)/3

        project.update(velocity_strategy: :past_iters_4)
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(9) # (6+8+10+12)/4
      end

      it 'adjusts for team strength' do
        # Create completed iterations with different team strengths
        create(:iteration,
               project: project,
               state: :done,
               start_date: 2.weeks.ago,
               end_date: 1.week.ago,
               number: 1,
               points_completed: 8,
               team_strength: 80) # 8 points at 80% = 10 points normalized

        create(:iteration,
               project: project,
               state: :done,
               start_date: 1.week.ago,
               end_date: Date.yesterday,
               number: 2,
               points_completed: 10,
               team_strength: 100) # 10 points at 100% = 10 points normalized

        # Calculate velocity with past_iters_2
        project.update(velocity_strategy: :past_iters_2)

        # Average should be (10 + 10) / 2 = 10
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(10)
      end

      it 'adjusts for iteration length' do
        # Create a completed iteration with 2-week length
        create(:iteration,
               project: project,
               state: :done,
               start_date: 2.weeks.ago,
               end_date: Date.yesterday, # 2 weeks length
               number: 1,
               points_completed: 16) # 16 points over 2 weeks = 8 points per week

        # Set project to use 2-week iterations
        project.update(velocity_strategy: :past_iters_1, iteration_length: 2)

        # Velocity should be 8 points/week * 2 weeks = 16 points
        expect(IterationPlanner.calculate_project_velocity(project)).to eq(16)
      end
    end
  end

  describe '.find_or_create_current_iteration' do
    it 'returns the current iteration if one exists' do
      current_iteration = create(:iteration,
                                project: project,
                                state: :current,
                                start_date: Date.today,
                                end_date: Date.today + 6.days)

      result = IterationPlanner.find_or_create_current_iteration(project)
      expect(result).to eq(current_iteration)
    end

    it 'returns an iteration containing today if one exists' do
      containing_iteration = create(:iteration,
                                    project: project,
                                    state: :backlog, # Not marked as current
                                    start_date: Date.yesterday,
                                    end_date: Date.tomorrow)

      result = IterationPlanner.find_or_create_current_iteration(project)
      expect(result).to eq(containing_iteration)
    end

    it 'creates a new iteration if none exists' do
      expect(project.iterations.count).to eq(0)

      result = IterationPlanner.find_or_create_current_iteration(project)

      expect(result).to be_persisted
      expect(result.state).to eq('current')
      expect(result.start_date).to eq(Date.new(2025, 5, 5)) # Monday
      expect(result.end_date).to eq(Date.new(2025, 5, 11))  # Sunday
    end
  end

  describe '.fill_current_iteration' do
    let(:current_iteration) do
      create(:iteration,
             project: project,
             state: :current,
             start_date: Date.today,
             end_date: Date.today + 6.days,
             velocity: 10)
    end

    it 'assigns current stories to the iteration' do
      # Create some stories in various current states
      started_story = create(:story, project: project, state: :started, estimate: 3)
      finished_story = create(:story, project: project, state: :finished, estimate: 2)
      delivered_story = create(:story, project: project, state: :delivered, estimate: 1)
      rejected_story = create(:story, project: project, state: :rejected, estimate: 2)

      IterationPlanner.fill_current_iteration(current_iteration)

      expect(current_iteration.stories).to include(started_story, finished_story, delivered_story, rejected_story)
    end

    it 'fills iteration with unstarted stories up to velocity' do
      # Create an existing current story using 3 points
      create(:story, project: project, state: :started, estimate: 3, iteration: current_iteration)

      # Create some unstarted stories
      story1 = create(:story, project: project, state: :unstarted, estimate: 3, position: 1)
      story2 = create(:story, project: project, state: :unstarted, estimate: 2, position: 2)
      story3 = create(:story, project: project, state: :unstarted, estimate: 3, position: 3)
      story4 = create(:story, project: project, state: :unstarted, estimate: 5, position: 4)

      IterationPlanner.fill_current_iteration(current_iteration)

      # Should include story1 and story2 (3 + 3 + 2 = 8 points)
      # But story3 would make it 11 points which exceeds velocity of 10
      expect(current_iteration.stories).to include(story1, story2)
      expect(current_iteration.stories).not_to include(story3, story4)
    end

    it 'includes unestimated stories without counting against velocity' do
      # Create an existing current story using 3 points
      create(:story, project: project, state: :started, estimate: 3, iteration: current_iteration)

      # Create some unstarted stories
      story1 = create(:story, project: project, state: :unstarted, estimate: 3, position: 1)
      story2 = create(:story, project: project, state: :unstarted, estimate: 2, position: 2)
      unestimated = create(:story, project: project, state: :unstarted, estimate: -1, position: 3)
      story3 = create(:story, project: project, state: :unstarted, estimate: 2, position: 4)

      IterationPlanner.fill_current_iteration(current_iteration)

      # Should include story1, story2, and unestimated (3 + 3 + 2 = 8 points)
      # Can also include story3 since we have 2 points left (10-8=2)
      expect(current_iteration.stories).to include(story1, story2, unestimated, story3)
    end
  end

  describe '.plan_future_iterations' do
    let!(:current_iteration) do
      create(:iteration,
             project: project,
             state: :current,
             start_date: Date.today,
             end_date: Date.today + 6.days,
             number: 1,
             velocity: 10)
    end

    it 'creates future iterations for unassigned stories respecting position' do
      # Create some unstarted stories with no iteration
      story1 = create(:story, project: project, state: :unstarted, estimate: 5, position: 2)
      story2 = create(:story, project: project, state: :unstarted, estimate: 8, position: 3)
      story3 = create(:story, project: project, state: :unstarted, estimate: 3, position: 4)
      story4 = create(:story, project: project, state: :unstarted, estimate: 5, position: 5)
      story5 = create(:story, project: project, state: :unstarted, estimate: 2, position: 6)

      IterationPlanner.plan_future_iterations(project)

      # Should create 3 future iterations:
      # Iteration 2: 5 points (5)
      # Iteration 3: 8 points (8)
      # Iteration 4: 10 points (3+5+2)
      expect(project.iterations.current.first.stories.count).to eq(0)

      expect(project.iterations.backlog.count).to eq(3)
      iterations = project.iterations.backlog.order(:number)

      # First backlog iteration (2)
      expect(iterations[0].number).to eq(2)
      expect(iterations[0].start_date).to eq(Date.today + 7.days) # Next period after current
      expect(iterations[0].stories.count).to eq(1)
      expect(iterations[0].stories.pluck(:id)).to match_array([story1.id])
      expect(iterations[0].stories.sum(:estimate)).to eq(5)

      # Second backlog iteration (3)
      expect(iterations[1].number).to eq(3)
      expect(iterations[1].start_date).to eq(Date.today + 14.days) # Following period
      expect(iterations[1].stories.count).to eq(1)
      expect(iterations[1].stories.pluck(:id)).to match_array([story2.id])
      expect(iterations[1].stories.sum(:estimate)).to eq(8)

      # Third backlog iteration (4)
      expect(iterations[2].number).to eq(4)
      expect(iterations[2].start_date).to eq(Date.today + 21.days) # Week after that
      expect(iterations[2].stories.count).to eq(3)
      expect(iterations[2].stories.pluck(:id)).to match_array([story3.id, story4.id, story5.id])
      expect(iterations[2].stories.sum(:estimate)).to eq(10)
    end

    it 'properly handles unestimated stories' do
      # Create some stories including unestimated ones
      story1 = create(:story, project: project, state: :unstarted, estimate: 8, position: 2)
      story2 = create(:story, project: project, state: :unstarted, estimate: -1, position: 3) # Unestimated
      story3 = create(:story, project: project, state: :unstarted, estimate: 5, position: 4)
      story4 = create(:story, project: project, state: :unstarted, estimate: -1, position: 5) # Unestimated

      IterationPlanner.plan_future_iterations(project)

      # Should create 2 future iterations:
      # Iteration 2: 8 points + 1 unestimated story
      # Iteration 3: 5 points + 1 unestimated story
      expect(project.iterations.backlog.count).to eq(2)
      iterations = project.iterations.backlog.order(:number)

      # First backlog iteration
      expect(iterations[0].stories.count).to eq(2)
      expect(iterations[0].stories.pluck(:id)).to match_array([story1.id, story2.id])
      expect(iterations[0].stories.estimated.sum(:estimate)).to eq(8)
      expect(iterations[0].stories.unestimated.count).to eq(1)

      # Second backlog iteration
      expect(iterations[1].stories.count).to eq(2)
      expect(iterations[1].stories.pluck(:id)).to match_array([story3.id, story4.id])
      expect(iterations[1].stories.estimated.sum(:estimate)).to eq(5)
      expect(iterations[1].stories.unestimated.count).to eq(1)
    end

    it 'creates a new iteration when a story exceeds velocity' do
      # Create a large story that exceeds velocity
      story1 = create(:story, project: project, state: :unstarted, estimate: 5, position: 2)
      story2 = create(:story, project: project, state: :unstarted, estimate: 12, position: 3) # Exceeds velocity
      story3 = create(:story, project: project, state: :unstarted, estimate: 3, position: 4)

      IterationPlanner.plan_future_iterations(project)

      # Should create 3 iterations:
      # Iteration 2: 5 points
      # Iteration 3: 12 points (exceeds velocity but respected due to position)
      # Iteration 4: 3 points
      expect(project.iterations.backlog.count).to eq(3)
      iterations = project.iterations.backlog.order(:number)

      expect(iterations[0].stories.count).to eq(1)
      expect(iterations[0].stories.first.id).to eq(story1.id)
      expect(iterations[0].stories.sum(:estimate)).to eq(5)

      expect(iterations[1].stories.count).to eq(1)
      expect(iterations[1].stories.first.id).to eq(story2.id)
      expect(iterations[1].stories.sum(:estimate)).to eq(12) # Exceeds velocity

      expect(iterations[2].stories.count).to eq(1)
      expect(iterations[2].stories.first.id).to eq(story3.id)
      expect(iterations[2].stories.sum(:estimate)).to eq(3)
    end

    it 'does nothing when there are no unassigned stories' do
      # All stories are already assigned to iterations
      create(:story, project: project, state: :unstarted, estimate: 5, iteration: current_iteration)
      expect(project.iterations.backlog.count).to eq(0)
      IterationPlanner.plan_future_iterations(project)
      expect(project.iterations.backlog.count).to eq(0)
    end
  end
end
