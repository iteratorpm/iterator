class NotificationsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, only: [:index]

  def index
    @notifications = current_user.notifications.recent
    apply_filters
    @unread_count = current_user.notifications.unread.count
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read
    redirect_back(fallback_location: notifications_path)
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back(fallback_location: notifications_path)
  end

  private

  def apply_filters
    case params[:filter]
    when 'unread'
      @notifications = @notifications.unread
    when 'mentions'
      @notifications = @notifications.with_mentions
    when 'project'
      @notifications = @notifications.for_project(params[:project_id])
    end

    @notifications = @notifications.order(created_at: :desc).page(params[:page])
  end
end
