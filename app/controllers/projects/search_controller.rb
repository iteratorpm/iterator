module Projects
  class SearchController < ApplicationController
    before_action :set_project
    before_action :parse_search_query, only: :index

    MAX_RESULTS = 500

    def index
      @search_results = {
        stories: search_stories,
        epics: search_epics,
        labels: search_labels
      }

      respond_to do |format|
        format.json { render json: @search_results }
      end
    end

    private

    def set_project
      @project = Project.find(params[:project_id])

      authorize! :read, @project
    end

    def parse_search_query
      @search_service = SearchQueryService.new(params[:q], @project)
    end

    def search_stories
      query = @search_service.stories_query
      @project.stories.ransack(query).result(distinct: true)
        .includes(:owners, :requester, :labels, :epic)
        .limit(MAX_RESULTS)
    end

    def search_epics
      query = @search_service.epics_query
      @project.epics.ransack(query).result(distinct: true)
        .limit(MAX_RESULTS)
    end

    def search_labels
      query = @search_service.labels_query
      @project.labels.ransack(query).result(distinct: true)
        .limit(MAX_RESULTS)
    end
  end
end
