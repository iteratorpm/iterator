require 'rails_helper'

RSpec.describe SearchQueryService do
  let(:project) { create(:project) }

  describe '#initialize' do
    it 'strips whitespace from query' do
      service = described_class.new("  hello  ", project)
      expect(service.original_query).to eq("hello")
    end

    it 'converts nil query to empty string' do
      service = described_class.new(nil, project)
      expect(service.original_query).to eq("")
    end
  end

  describe 'with blank query' do
    let(:service) { described_class.new("", project) }

    describe '#stories_query' do
      it 'returns no results query' do
        expect(service.stories_query).to eq({ id_eq: 0 })
      end
    end

    describe '#epics_query' do
      it 'returns no results query' do
        expect(service.epics_query).to eq({ id_eq: 0 })
      end
    end

    describe '#labels_query' do
      it 'returns no results query' do
        expect(service.labels_query).to eq({ id_eq: 0 })
      end
    end
  end

  describe 'with simple text query' do
    let(:service) { described_class.new("search term", project) }

    describe '#stories_query' do
      it 'builds correct search query' do
        expect(service.stories_query).to eq({
          name_or_description_or_comments_content_or_tasks_description_cont: "search term"
        })
      end
    end

    describe '#epics_query' do
      it 'builds correct search query' do
        expect(service.epics_query).to eq({
          name_or_description_cont: "search term"
        })
      end
    end

    describe '#labels_query' do
      it 'builds correct search query' do
        expect(service.labels_query).to eq({
          name_cont: "search term"
        })
      end
    end
  end

  describe 'with field filters' do
    let(:service) { described_class.new('state:open label:bug,urgent owner:john', project) }

    describe '#stories_query' do
      it 'builds correct search query' do
        expect(service.stories_query).to eq({
          state_eq: "open",
          labels_name_in: ["bug", "urgent"],
          owners_name_or_owners_username_cont: "john"
        })
      end
    end
  end

  describe 'with negated filters' do
    let(:service) { described_class.new('-state:closed -label:feature', project) }

    describe '#parse_query' do
      it 'correctly parses negated filters' do
        expect(service.instance_variable_get(:@negated_filters)).to eq({
          "state" => "closed",
          "label" => "feature"
        })
      end
    end
  end

  describe 'with quoted terms' do
    let(:service) { described_class.new('"exact phrase" name:"john doe"', project) }

    describe '#parse_query' do
      it 'strips quotes from terms' do
        expect(service.instance_variable_get(:@text_terms)).to eq(["exact phrase"])
        expect(service.instance_variable_get(:@field_filters)).to eq({
          "name" => "john doe"
        })
      end
    end
  end

  describe 'with complex query' do
    let(:service) { described_class.new('status:open type:bug "high priority" -owner:jane', project) }

    describe '#stories_query' do
      it 'combines text terms and filters correctly' do
        expect(service.stories_query).to include({
          story_type_eq: "bug",
          name_or_description_or_comments_content_or_tasks_description_cont: "high priority"
        })
      end
    end
  end

  describe 'query memoization' do
    let(:service) { described_class.new("search", project) }

    it 'memoizes the query builders' do
      expect(service.stories_query.object_id).to eq(service.stories_query.object_id)
      expect(service.epics_query.object_id).to eq(service.epics_query.object_id)
      expect(service.labels_query.object_id).to eq(service.labels_query.object_id)
    end
  end
end
