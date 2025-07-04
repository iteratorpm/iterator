require 'rails_helper'

RSpec.describe "Projects::Stories", type: :request do
  let(:project) { create(:project, :with_members) }
  let(:user) { project.project_memberships.first.user }
  let(:story) { create(:story, project: project) }

  before do
    sign_in user
  end

  describe "GET /blocked" do
    context "when accessing blocked" do
      before do
        story = create(:story, :icebox, project: project)
        create(:story_owner, story: story, user: user)
      end

      it "returns success for blocked" do
        get blocked_project_stories_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Blocked")
      end
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "raises authorization error" do
        get blocked_project_stories_path(project)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /edit" do
    context "when accessing edit" do
      before do
        story = create(:story, :icebox, project: project)
        create(:story_owner, story: story, user: user)
      end

      it "returns success for blocked" do
        get edit_project_story_path(project, story)
        expect(response).to be_successful
        expect(response.body).to include(story.name)
      end
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "raises authorization error" do
        get edit_project_story_path(project, story)
        expect(response).to be_access_denied
      end
    end
  end

  describe "GET /my_work" do
    context "when accessing my_work" do
      before do
        story = create(:story, :icebox, project: project)
        create(:story_owner, story: story, user: user)
      end

      it "returns success for my_work" do
        get my_work_project_stories_path(project)
        expect(response).to be_successful
        expect(response.body).to include("My Work")
      end
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "raises authorization error" do
        get my_work_project_stories_path(project)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /icebox" do
    context "when accessing icebox" do
      before do
        create_list(:story, 2, :icebox, project: project)
      end

      it "returns success for icebox" do
        get icebox_project_stories_path(project)
        expect(response).to be_successful
        expect(response.body).to include("Icebox")
      end
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "raises authorization error" do
        get icebox_project_stories_path(project)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "DELETE /destroy" do
    context "with valid parameters" do
      it "destroys the requested story" do
        story = create(:story, project: project)
        expect {
          delete project_story_path(project, story)
        }.to change(Story, :count).by(-1)
      end

      it "redirects with notice for HTML format" do
        delete project_story_path(project, story)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:notice]).to eq('Story was successfully deleted.')
      end

      it "returns turbo stream for TURBO_STREAM format" do
        delete project_story_path(project, story), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"remove\" target=\"#{dom_id(story)}\"")
      end

      it "returns no content for JSON format" do
        delete project_story_path(project, story), headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:no_content)
      end
    end

    context.skip "when destruction fails" do
      before do
        allow_any_instance_of(Story).to receive(:destroy).and_return(false)
        allow_any_instance_of(Story).to receive(:clear)
        allow_any_instance_of(Story).to receive(:errors).and_return(double(full_messages: ["Cannot delete story"]))
      end

      it "does not destroy the story" do
        expect {
          delete project_story_path(project, story)
        }.not_to change(Story, :count)
      end

      it "redirects with alert for HTML format" do
        delete project_story_path(project, story)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq('Failed to delete story.')
      end

      it "returns unprocessable entity for TURBO_STREAM format" do
        delete project_story_path(project, story), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("turbo-stream action=\"replace\" target=\"#{dom_id(story)}\"")
      end

      it "returns error for JSON format" do
        delete project_story_path(project, story), headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Failed to delete story')
      end
    end
  end

  # Example tests for other actions for completeness
  describe "POST /create" do
    let(:valid_attributes) { attributes_for(:story, requester_id: user.id) }

    context "with valid parameters" do
      it "creates a new Story" do
        expect {
          post project_stories_path(project), params: { story: valid_attributes }
        }.to change(Story, :count).by(1)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) { { name: "Updated Title" } }

    it "updates the requested story" do
      patch project_story_path(project, story), params: { story: new_attributes }
      story.reload
      expect(story.name).to eq("Updated Title")
    end

    context "when starting the story" do
      let(:story) { create(:story, project: project, state: :unstarted) }

      before do
        patch project_story_path(project, story), params: { story: { state: "started" } }
        story.reload
      end

      it "adds the current user as an owner" do
        expect(story.owners).to include(user)
      end

      it "sets the started_at timestamp" do
        expect(story.started_at).to be_present
      end
    end

    context "updating name" do
      let(:new_attributes) { { name: "Updated Title" } }

      it "updates the requested story" do
        patch project_story_path(project, story), params: { story: new_attributes }
        story.reload
        expect(story.name).to eq("Updated Title")
      end
    end

    context "updating position" do
      let!(:story1) { create(:story, project: project, state: :unstarted) }
      let!(:story2) { create(:story, project: project, state: :unstarted) }

      it "moves the story after another story" do
        patch project_story_path(project, story1), params: {
          story: {
            position: { after: story2.id }
          }
        }
        wanted_pos = story2.position
        original_pos = story1.position

        story1.reload
        story2.reload

        expect(story1.position).to eq wanted_pos
        expect(story2.position).to eq original_pos
      end
    end

    context "moving between columns (states)" do
      it "updates the state from unscheduled to unstarted" do
        story.update!(state: :unscheduled)

        patch project_story_path(project, story), params: {
          story: { state: :unstarted }
        }

        story.reload
        expect(story.state).to eq("unstarted")
      end
    end

    context.skip "assigning to an epic adds the epic label" do
      let(:epic) { create(:epic, :label, project: project) }

      it "assigns the epic and adds the label" do
        patch project_story_path(project, story), params: {
          story: { epic_id: epic.id }
        }

        story.reload
        expect(story.epic).to eq(epic)
        expect(story.labels).to include(epic.label)
      end
    end
  end

  describe "GET /rejection" do
    let(:story) { create(:story, project: project) }

    it "renders the rejection form turbo frame" do
      get rejection_project_story_path(project, story), headers: { "Turbo-Frame" => "modal" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reason for Rejection")
    end

    context "when user is not authorized" do
      let(:non_member) { create(:user) }

      before do
        sign_in non_member
      end

      it "returns 302 if unauthorized" do
        get rejection_project_story_path(project, story)

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "PATCH /reject" do
    let(:story) { create(:story, project: project, state: :delivered) }

    context "with a comment" do
      let(:comment_body) { "This doesn't meet requirements." }

      it "adds a comment and updates the story state to rejected" do
        expect {
          patch reject_project_story_path(project, story),
          params: { story: { comment: comment_body } },
          headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
        }.to change { story.comments.count }.by(1)

        story.reload
        expect(story.state).to eq("rejected")
        expect(story.comments.last.content).to eq(comment_body)
      end
    end

    context "without a comment" do
      it "rejects the story without creating a comment" do
        expect {
          patch reject_project_story_path(project, story),
          params: { story: { comment: "" } },
          headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
        }.not_to change { story.comments.count }

        story.reload
        expect(story.state).to eq("rejected")
      end
    end

    context "when rejection fails" do
      before do
        allow_any_instance_of(StoryService).to receive(:update).and_return(false)
      end

      it "redirects with an error alert" do
        patch reject_project_story_path(project, story),
          params: { story: { comment: "" } }

        expect(response).to redirect_to(project_path(project))
      end
    end
  end
end
