class NotificationsController < ApplicationController
  authorize_resource
  before_action :authenticate_user!

  PER_PAGE = 15

  def index
    @notifications = current_user.notifications.recent.includes(:project, :notifiable)
    apply_filters
    @notifications = @notifications.order(created_at: :desc)

    # Pagination
    page = params[:page]&.to_i || 1
    offset = (page - 1) * PER_PAGE
    paginated_notifications = @notifications.limit(PER_PAGE).offset(offset)

    respond_to do |format|
      format.html { @notifications = paginated_notifications }
      format.json do
        notifications_data = paginated_notifications.map do |notification|
          {
            id: notification.id,
            notification_type: notification.notification_type,
            message: notification.message,
            created_at: notification.created_at,
            read_at: notification.read_at,
            project_name: notification.project&.name,
            story_name: notification.story_name,
            story_url: notification.story_url
          }
        end

        total_count = @notifications.count
        has_more = total_count > (page * PER_PAGE)

        render json: {
          notifications: notifications_data,
          has_more: has_more,
          next_page: has_more ? page + 1 : nil,
          total_count: total_count
        }
      end
    end
  end

  def unread_count
    count = current_user.notifications.recent.unread.count
    render json: { count: count }
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true, message: 'Notification marked as read' } }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true, message: 'All notifications marked as read' } }
    end
  end

  private

  def apply_filters
    case params[:filter]
    when 'unread'
      @notifications = @notifications.unread
    when 'mentions'
      @notifications = @notifications.with_mentions
    when 'stories'
      @notifications = @notifications.where(notification_type: [
        :story_created, :story_delivered, :story_accepted, :story_rejected,
        :story_assigned, :story_blocking
      ])
    when 'project'
      @notifications = @notifications.for_project(params[:project_id]) if params[:project_id].present?
    end
  end

end
