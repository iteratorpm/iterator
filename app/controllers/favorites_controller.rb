class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @project = Project.find(params[:project_id])
    current_user.favorites.create(project: @project)
    redirect_back fallback_location: projects_path, notice: 'Project added to favorites'
  end

  def destroy
    @project = Project.find(params[:id])
    current_user.favorites.where(project: @project).destroy_all
    redirect_back fallback_location: projects_path, notice: 'Project removed from favorites'
  end
end
