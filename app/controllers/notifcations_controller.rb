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

# app/controllers/notification_settings_controller.rb
class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @global_settings = current_user.notification_settings.find_or_initialize_by(project: nil)
    @project_settings = current_user.notification_settings.where.not(project: nil).includes(:project)
    @muted_projects = current_user.muted_projects.includes(:project)
    @projects = current_user.projects
  end

  def update
    @settings = current_user.notification_settings.find_or_initialize_by(
      project_id: params[:notification_setting][:project_id]
    )

    if @settings.update(notification_setting_params)
      redirect_to edit_notification_settings_path, notice: 'Settings updated successfully'
    else
      render :edit
    end
  end

  def toggle_mute_project
    project = Project.find(params[:project_id])

    if params[:mute_type] == 'unmute'
      current_user.muted_projects.where(project: project).destroy_all
    else
      muted_project = current_user.muted_projects.find_or_initialize_by(project: project)
      muted_project.mute_type = params[:mute_type]
      muted_project.save
    end

    redirect_to edit_notification_settings_path, notice: 'Project mute settings updated'
  end

  private

  def notification_setting_params
    params.require(:notification_setting).permit(
      :project_id, :story_creation, :comments, :comment_source,
      :story_state_changes, :blockers, :comment_reactions, :reviews,
      :in_app_status, :email_status, :email_titles_enabled
    )
  end
end
