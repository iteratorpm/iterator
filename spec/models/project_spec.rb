require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { create(:project, time_zone: 'UTC', iteration_start_day: 'monday') }

  describe '#calculate_iteration_start_date' do
    context 'when iteration starts on Monday' do
      before { project.update(iteration_start_day: 'monday') }

      it 'returns current Monday when today is Monday' do
        monday = Date.new(2023, 1, 2) # Known Monday
        travel_to(monday) do
          expect(project.calculate_iteration_start_date).to eq(monday)
        end
      end

      it 'returns previous Monday when today is Wednesday' do
        wednesday = Date.new(2023, 1, 4) # Known Wednesday
        travel_to(wednesday) do
          expect(project.calculate_iteration_start_date).to eq(Date.new(2023, 1, 2))
        end
      end

      it 'returns previous Monday when today is Sunday' do
        sunday = Date.new(2023, 1, 8) # Known Sunday
        travel_to(sunday) do
          expect(project.calculate_iteration_start_date).to eq(Date.new(2023, 1, 2))
        end
      end
    end

    context 'when iteration starts on Wednesday' do
      before { project.update(iteration_start_day: 'wednesday') }

      it 'returns current Wednesday when today is Wednesday' do
        wednesday = Date.new(2023, 1, 4) # Known Wednesday
        travel_to(wednesday) do
          expect(project.calculate_iteration_start_date).to eq(wednesday)
        end
      end

      it 'returns previous Wednesday when today is Friday' do
        friday = Date.new(2023, 1, 6) # Known Friday
        travel_to(friday) do
          expect(project.calculate_iteration_start_date).to eq(Date.new(2023, 1, 4))
        end
      end

      it 'returns previous Wednesday when today is Tuesday' do
        tuesday = Date.new(2023, 1, 3) # Known Tuesday
        travel_to(tuesday) do
          expect(project.calculate_iteration_start_date).to eq(Date.new(2022, 12, 28))
        end
      end
    end

    context 'with different time zones' do
      let(:tokyo_project) { create(:project, time_zone: 'Tokyo', iteration_start_day: 'monday') }

      it 'respects time zone when crossing midnight' do
        # 11pm UTC is 8am next day in Tokyo
        travel_to(Time.utc(2023, 1, 1, 23, 0, 0)) do
          # In Tokyo time zone, this is already Monday Jan 2
          expect(tokyo_project.calculate_iteration_start_date).to eq(Date.new(2023, 1, 2))
        end
      end
    end
  end

  describe '#find_or_create_current_iteration' do
    it 'delegates to Iteration.find_or_create_current_iteration' do
      expect(Iteration).to receive(:find_or_create_current_iteration).with(project)
      project.find_or_create_current_iteration
    end
  end
end
