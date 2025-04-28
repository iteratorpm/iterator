require 'rails_helper'

RSpec.describe "Projects::Stories", type: :request do
  let(:project) { create(:project, :with_members) }
  let(:user) { project.memberships.first.user }
  let(:story) { create(:story, project: project) }

  before do
    sign_in user
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
  end

end
