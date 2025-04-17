class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, except: [:remove_avatar]

  def recent_analytics
    redirect_to project_analytics_path @user.projects.first
  end

  # GET /profile
  def show
    respond_to do |format|
      format.html # show.html.slim
    end
  end

  # PATCH/PUT /profile
  def update
    section = profile_params[:section]

    case section
    when 'general'
      update_general_profile
    when 'email_and_password'
      update_email_and_password
    else
      flash[:alert] = "Invalid profile section"
      redirect_to profile_path
    end
  end

  # POST /profile/tokens
  def create_token
    @user = current_user
    @user.regenerate_api_token
    respond_to do |format|
      format.turbo_stream
    end
  end

  # DELETE /profile/tokens/:id
  def destroy_token
    @user = current_user
    @user.clear_api_token!
    respond_to do |format|
      format.turbo_stream
    end
  end

  # POST /profile/avatar
  def update_avatar
    if @user.avatar.attach(avatar_params[:avatar])
      respond_to do |format|
        format.html { redirect_to profile_path, notice: 'Profile photo updated successfully.' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to profile_path, alert: 'Failed to update profile photo.' }
        format.turbo_stream
      end
    end
  end

  # DELETE /profile/avatar
  def remove_avatar
    @user = current_user
    @user.avatar.purge
    respond_to do |format|
      format.html { redirect_to profile_path, notice: 'Profile photo removed successfully.' }
      format.turbo_stream
    end
  end

  # DELETE /profile/revoke_app/:id
  def revoke_app
    app = current_user.authorized_apps.find(params[:id])
    app.destroy
    respond_to do |format|
      format.html { redirect_to profile_path, notice: "#{app.name} access revoked." }
      format.turbo_stream
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(
      :section,
      :username,
      :name,
      :initials,
      :time_zone,
      :default_story_type_value,
      :email,
      :password,
      :password_confirmation,
      :current_password
    )
  end

  def avatar_params
    params.require(:user).permit(:avatar)
  end

  def update_general_profile
    if @user.update(profile_params.except(:section, :current_password))
      bypass_sign_in(@user) # Keep user logged in if they change their username
      flash[:notice] = "Profile updated successfully."
      redirect_to profile_path
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  def update_email_and_password
    if @user.update_with_password(profile_params)
      bypass_sign_in(@user) # Keep user logged in after password change
      flash[:notice] = "Email and password updated successfully."
      redirect_to profile_path
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end
end
