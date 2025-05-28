require 'rails_helper'

RSpec.describe "Projects::Search", type: :request do
  let(:project) { create(:project, :with_members) }
  let(:user) { project.memberships.first.user }

  let!(:epic) { create(:epic, :with_label, project: project, name: "Important Epic") }
  let!(:story) { create(:story, :with_epic, :with_labels, project: project, name: "Critical Story") }
  let!(:label) { create(:label, project: project, name: "Urgent Label") }

  before do
    sign_in user
  end

  describe "GET /index" do
    context "with HTML format" do
      it "renders a successful response" do
        get project_search_path(project)
        expect(response).to be_successful
      end
    end

    context "with Turbo Stream format" do
      it "renders a successful response" do
        get project_search_path(project), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to be_successful
        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end
    end

    context "with JSON format" do
      it "renders a successful response" do
        get project_search_path(project), as: :json
        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end

    context "when searching for epics" do
      it "returns matching epics" do
        get project_search_path(project, q: "Important")
        expect(assigns(:search_results)[:epics]).to include(epic)
      end

      it "does not return non-matching epics" do
        get project_search_path(project, q: "Nonexistent")
        expect(assigns(:search_results)[:epics]).not_to include(epic)
      end
    end

    context "when searching for stories" do
      it "returns matching stories" do
        get project_search_path(project, q: "Critical")
        expect(assigns(:search_results)[:stories]).to include(story)
      end

      it "does not return non-matching stories" do
        get project_search_path(project, q: "Nonexistent")
        expect(assigns(:search_results)[:stories]).not_to include(story)
      end
    end

    context "when searching for labels" do
      it "returns matching labels" do
        epic.label.update name: "Urgent Epic Label"

        get project_search_path(project, q: "Urgent")
        # Should find both the standalone label and the epic's label
        expect(assigns(:search_results)[:labels]).to include(label, epic.label)
      end

      it "does not return non-matching labels" do
        get project_search_path(project, q: "Nonexistent")
        expect(assigns(:search_results)[:labels]).not_to include(label)
      end
    end

    context "with empty search query" do
      it "returns empty results" do
        get project_search_path(project, q: "")
        expect(assigns(:search_results)[:epics]).to be_empty
        expect(assigns(:search_results)[:stories]).to be_empty
        expect(assigns(:search_results)[:labels]).to be_empty
      end
    end

    context "when unauthorized" do
      let(:other_user) { create(:user) }

      before do
        sign_in other_user
      end

      it "raises an authorization error" do
        get project_search_path(project)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
