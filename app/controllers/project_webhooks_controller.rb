class ProjectWebhooksController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, only: [:index]

  def index
  end

end
