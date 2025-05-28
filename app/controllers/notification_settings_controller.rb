class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification_setting, only: [:update]

  def index
    @notification_setting = current_user.notification_setting ||
                           current_user.create_notification_setting
    @muted_projects = current_user.muted_projects.includes(:project)
    @projects = current_user.projects
  end

  def update
    respond_to do |format|
      format.turbo_stream do
        case params[:section]
        when 'in_app'
          update_in_app_settings
        when 'email'
          update_email_settings
        else
          render_error("Invalid section")
        end
      end
      format.json { render json: { status: 'success' } }
    end
  end

  private

  def set_notification_setting
    @notification_setting = current_user.notification_setting ||
                           current_user.create_notification_setting
  end

  def update_in_app_settings
    settings_params = {
      in_app_story_creation: map_notification_value(params[:in_app_new]),
      in_app_story_state_changes: map_story_state_value(params[:in_app_story_state]),
      in_app_comments: map_comment_value(params[:in_app_comments]),
      in_app_blockers: map_blocker_value(params[:in_app_blockers]),
      in_app_comment_reactions: map_reaction_value(params[:in_app_reactions]),
      in_app_reviews: map_review_value(params[:in_app_reviews])
    }

    if @notification_setting.update(settings_params)
      render turbo_stream: turbo_stream.replace("in_app_section",
        partial: "in_app_section", locals: { settings: @notification_setting })
    else
      render_error("Failed to update in-app settings", @notification_setting.errors)
    end
  end

  def update_email_settings
    settings_params = {
      email_story_creation: map_notification_value(params[:email_new]),
      email_story_state_changes: map_story_state_value(params[:email_story_state]),
      email_comments: map_comment_value(params[:email_comments]),
      email_blockers: map_blocker_value(params[:email_blockers]),
      email_comment_reactions: map_reaction_value(params[:email_reactions]),
      email_reviews: map_review_value(params[:email_reviews])
    }

    if @notification_setting.update(settings_params)
      render turbo_stream: turbo_stream.replace("email_section",
        partial: "email_section", locals: { settings: @notification_setting })
    else
      render_error("Failed to update email settings", @notification_setting.errors)
    end
  end

  def render_error(message, errors = nil)
    render turbo_stream: turbo_stream.prepend("flash_messages",
      partial: "shared/flash_message",
      locals: {
        type: "error",
        message: message,
        errors: errors
      })
  end

  # Helper methods to map form values to database enums
  def map_notification_value(value)
    value == '1' ? 1 : 0
  end

  def map_story_state_value(value)
    case value
    when 'no' then 0
    when 'relevant' then 1
    when 'all' then 2
    else 1
    end
  end

  def map_comment_value(value)
    case value
    when 'no' then 0
    when 'mentions' then 1
    when 'all' then 2
    else 1
    end
  end

  def map_blocker_value(value)
    case value
    when 'no' then 0
    when 'followed' then 1
    when 'all' then 2
    else 1
    end
  end

  def map_reaction_value(value)
    value == '1' ? 1 : 0
  end

  def map_review_value(value)
    value == '1' ? 1 : 0
  end
end
