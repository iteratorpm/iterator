require 'rails_helper'

RSpec.describe NotificationSettingsController, type: :request do
  let(:user) { create(:user) }
  let(:notification_setting) { create(:notification_setting, user: user) }

  before do
    sign_in user
  end

  describe "GET /notification_settings" do
    it "returns http success" do
      get notification_settings_path
      expect(response).to have_http_status(:success)
    end

    it "creates notification settings if they don't exist" do
      expect {
        get notification_settings_path
      }.to change(NotificationSetting, :count).by(1)
    end

    it "uses existing notification settings if they exist" do
      notification_setting
      expect {
        get notification_settings_path
      }.not_to change(NotificationSetting, :count)
      expect(assigns(:notification_setting)).to eq(notification_setting)
    end
  end

  describe "PATCH /notification_settings" do
    context "with turbo stream format" do
      context "for in_app section" do
        let(:valid_params) do
          {
            section: 'in_app',
            in_app_new: '1',
            in_app_story_state: 'all',
            in_app_comments: 'mentions',
            in_app_blockers: 'followed',
            in_app_reactions: '1',
            in_app_reviews: '1',
            format: :turbo_stream
          }
        end

        it "updates in-app notification settings" do
          patch notification_settings_path, params: valid_params
          expect(user.notification_setting.reload).to have_attributes(
            in_app_story_creation: 'yes',
            in_app_story_state_changes: 'all',
            in_app_comments: 'mentions_only',
            in_app_blockers: 'followed_stories',
            in_app_comment_reactions: 'yes',
            in_app_reviews: 'yes'
          )
        end

        it "renders turbo stream response" do
          patch notification_settings_path, params: valid_params
          expect(response).to have_http_status(:success)
          expect(response.media_type).to eq Mime[:turbo_stream]
        end

        it "renders error when update fails" do
          allow_any_instance_of(NotificationSetting).to receive(:update).and_return(false)
          patch notification_settings_path, params: valid_params
          expect(response).to have_http_status(:success)
          expect(response.body).to include('Failed to update in-app settings')
        end
      end

      context "for email section" do
        let(:valid_params) do
          {
            section: 'email',
            email_new: '1',
            email_story_state: 'relevant',
            email_comments: 'all',
            email_blockers: 'all',
            email_reactions: '0',
            email_reviews: '1',
            format: :turbo_stream
          }
        end

        it "updates email notification settings" do
          patch notification_settings_path, params: valid_params
          expect(user.notification_setting.reload).to have_attributes(
            email_story_creation: 'yes',
            email_story_state_changes: 'relevant',
            email_comments: 'all',
            email_blockers: 'all',
            email_comment_reactions: 'no',
            email_reviews: 'yes'
          )
        end

        it "renders turbo stream response" do
          patch notification_settings_path, params: valid_params
          expect(response).to have_http_status(:success)
          expect(response.media_type).to eq Mime[:turbo_stream]
        end
      end

      context "with invalid section" do
        it "renders error message" do
          patch notification_settings_path, params: { section: 'invalid', format: :turbo_stream }
          expect(response.body).to include('Invalid section')
        end
      end
    end

    context "with json format" do
      it "returns success status" do
        patch notification_settings_path, params: { section: 'in_app', format: :json }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'success' })
      end
    end
  end

  describe "helper methods" do
    let(:controller) { NotificationSettingsController.new }

    describe "#map_notification_value" do

      it "maps '1' to 1" do
        expect(controller.send(:map_notification_value, '1')).to eq(1)
      end

      it "maps other values to 0" do
        expect(controller.send(:map_notification_value, '0')).to eq(0)
      end
    end

    describe "#map_story_state_value" do
      it "maps values correctly" do
        expect(controller.send(:map_story_state_value, 'no')).to eq(0)
        expect(controller.send(:map_story_state_value, 'relevant')).to eq(1)
        expect(controller.send(:map_story_state_value, 'all')).to eq(2)
        expect(controller.send(:map_story_state_value, 'invalid')).to eq(1) # default
      end
    end

    describe "#map_comment_value" do
      it "maps values correctly" do
        expect(controller.send(:map_comment_value, 'no')).to eq(0)
        expect(controller.send(:map_comment_value, 'mentions')).to eq(1)
        expect(controller.send(:map_comment_value, 'all')).to eq(2)
        expect(controller.send(:map_comment_value, 'invalid')).to eq(1) # default
      end
    end

    describe "#map_blocker_value" do
      it "maps values correctly" do
        expect(controller.send(:map_blocker_value, 'no')).to eq(0)
        expect(controller.send(:map_blocker_value, 'followed')).to eq(1)
        expect(controller.send(:map_blocker_value, 'all')).to eq(2)
        expect(controller.send(:map_blocker_value, 'invalid')).to eq(1) # default
      end
    end

    describe "#map_reaction_value" do
      it "maps values correctly" do
        expect(controller.send(:map_reaction_value, '1')).to eq(1)
        expect(controller.send(:map_reaction_value, '0')).to eq(0)
      end
    end

    describe "#map_review_value" do
      it "maps values correctly" do
        expect(controller.send(:map_review_value, '1')).to eq(1)
        expect(controller.send(:map_review_value, '0')).to eq(0)
      end
    end
  end
end
