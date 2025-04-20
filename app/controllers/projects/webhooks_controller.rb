class Projects::WebhooksController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, only: [:index]

  before_action :set_project
  before_action :set_webhook, only: [:destroy, :toggle]

  def index
    @webhooks = @project.webhooks
  end

  def create
    @webhook = @project.webhooks.new(webhook_params)
    if @webhook.save
      render json: @webhook, status: :created
    else
      render json: @webhook.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @webhook.destroy
    head :no_content
  end

  def toggle
    @webhook.update(enabled: params[:enabled])
    head :ok
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_webhook
    @webhook = @project.webhooks.find(params[:id])
  end

  def webhook_params
    params.require(:webhook).permit(:webhook_url)
  end
end
