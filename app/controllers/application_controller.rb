class ApplicationController < ActionController::Base
  include TurboValidations
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: {ie: false}

  protect_from_forgery with: :exception
  around_action :use_user_time_zone, if: :current_user
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_recent_projects, if: :current_user

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { render nothing: true, status: :not_found }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { render nothing: true, status: :not_found }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name])
    devise_parameter_sanitizer.permit(:invite, keys: [:username, :name])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name, :username])
  end

  def use_user_time_zone(&block)
    Time.use_zone(current_user.time_zone.presence || 'UTC', &block)
  end

  def set_recent_projects
    @recent_projects = Project.joins(:project_memberships)
      .where(project_memberships: { user_id: current_user.id })
      .order(created_at: :desc)
      .limit(5)
  end
end
