class Projects::HistoriesController < Projects::BaseController

  def index
    @panel_id = "history_panel"
    @activities = PublicActivity::Activity.where(recipient: @project)
      .includes(:owner, :trackable)
      .order('created_at DESC')
      .page(params[:page])
  end

end
