require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { create(:project) }
  let!(:notifications) { create_list(:notification, 5, user: user, notifiable: user) }
  let!(:unread_notifications) { create_list(:notification, 3, :unread, user: user, notifiable: user) }
  let!(:other_user_notifications) { create_list(:notification, 2, notifiable: user, user: other_user) }

  before do
    sign_in user
  end

  describe "GET /notifications" do
    context "as HTML" do
      it "returns http success" do
        get notifications_path
        expect(response).to have_http_status(:success)
      end

      it "only shows current user's notifications" do
        get notifications_path
        expect(assigns(:notifications).map(&:user_id).uniq).to eq([user.id])
      end

      it "paginates results" do
        create_list(:notification, 20, user: user)
        get notifications_path
        expect(assigns(:notifications).size).to be <= NotificationsController::PER_PAGE
      end
    end

    context "as JSON" do
      it "returns paginated notifications with metadata" do
        get notifications_path(format: :json)
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(json_response["notifications"].count).to be <= NotificationsController::PER_PAGE
        expect(json_response).to have_key("has_more")
        expect(json_response).to have_key("next_page")
        expect(json_response).to have_key("total_count")
      end

      context "with filters" do
        it "filters by unread" do
          get notifications_path(format: :json), params: { filter: 'unread' }
          json_response = JSON.parse(response.body)
          expect(json_response["total_count"]).to eq(3)
        end

        it "filters by project" do
          project_notifications = create_list(:notification, 2, user: user, project: project)
          get notifications_path(format: :json), params: { filter: 'project', project_id: project.id }
          json_response = JSON.parse(response.body)
          expect(json_response["total_count"]).to eq(2)
        end

        it "filters by mentions" do
          mention_notifications = create_list(:notification, 2, user: user, notification_type: :mention_in_comment)
          get notifications_path(format: :json), params: { filter: 'mentions' }
          json_response = JSON.parse(response.body)
          expect(json_response["total_count"]).to eq(2)
        end

        it "filters by stories" do
          story_notifications = create_list(:notification, 2, user: user, notification_type: :story_created)
          get notifications_path(format: :json), params: { filter: 'stories' }
          json_response = JSON.parse(response.body)
          expect(json_response["total_count"]).to eq(2)
        end
      end
    end

    context "when unauthorized" do
      before { sign_out user }

      it "denies access" do
        get notifications_path
        expect(response).to be_access_denied
      end
    end
  end

  describe "GET /notifications/unread_count" do
    it "returns unread count" do
      get unread_count_notifications_path
      json_response = JSON.parse(response.body)
      expect(json_response["count"]).to eq(3)
    end

    context "when unauthorized" do
      before { sign_out user }

      it "denies access" do
        get unread_count_notifications_path
        expect(response).to be_access_denied
      end
    end
  end

  describe "PATCH /notifications/:id/mark_as_read" do
    let(:notification) { unread_notifications.first }

    context "as HTML" do
      it "marks notification as read and redirects" do
        patch mark_as_read_notification_path(notification)
        expect(notification.reload.read_at).not_to be_nil
        expect(response).to redirect_to(notifications_path)
      end
    end

    context "as JSON" do
      it "marks notification as read and returns success" do
        patch mark_as_read_notification_path(notification, format: :json)
        json_response = JSON.parse(response.body)
        expect(notification.reload.read_at).not_to be_nil
        expect(json_response["success"]).to be true
      end
    end

    context "when unauthorized" do
      before { sign_out user }

      it "denies access" do
        patch mark_as_read_notification_path(notification)
        expect(response).to be_access_denied
      end
    end

    context "when trying to mark another user's notification" do
      let(:other_notification) { other_user_notifications.first }

      it "denies access" do
        patch mark_as_read_notification_path(other_notification)
        expect(response).to be_access_denied
      end
    end
  end

  describe "POST /notifications/mark_all_as_read" do
    context "as HTML" do
      it "marks all notifications as read and redirects" do
        patch mark_all_as_read_notifications_path
        expect(user.notifications.unread.count).to eq(0)
        expect(response).to redirect_to(notifications_path)
      end
    end

    context "as JSON" do
      it "marks all notifications as read and returns success" do
        patch mark_all_as_read_notifications_path(format: :json)
        json_response = JSON.parse(response.body)
        expect(user.notifications.unread.count).to eq(0)
        expect(json_response["success"]).to be true
      end
    end

    context "when unauthorized" do
      before { sign_out user }

      it "denies access" do
        patch mark_all_as_read_notifications_path
        expect(response).to be_access_denied
      end
    end
  end
end
