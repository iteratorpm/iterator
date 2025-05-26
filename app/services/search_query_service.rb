class SearchQueryService
  attr_reader :original_query, :project

  def initialize(query, project)
    @original_query = query.to_s.strip
    @project = project
    parse_query
  end

  def stories_query
    return no_results_query if @original_query.blank?
    @stories_query ||= build_stories_query
  end

  def epics_query
    return no_results_query if @original_query.blank?
    @epics_query ||= build_epics_query
  end

  def labels_query
    return no_results_query if @original_query.blank?
    @labels_query ||= build_labels_query
  end

  private

  def no_results_query
    { id_eq: 0 } # This will return no results
  end

  def parse_query
    # Initialize instance variables to store parsed components
    @text_terms = []
    @field_filters = {}
    @negated_filters = {}
    @boolean_operators = []

    return if @original_query.blank?

    # Simple parsing logic - you'll want to expand this significantly
    terms = @original_query.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/)

    terms.each do |term|
      if term.include?(':')
        field, value = term.split(':', 2)
        value = value.gsub(/^"|"$/, '') if value.start_with?('"') && value.end_with?('"')

        if field.start_with?('-')
          @negated_filters[field[1..-1]] = value
        else
          @field_filters[field] = value
        end
      else
        @text_terms << term.gsub(/^"|"$/, '')
      end
    end
  end

  def build_stories_query
    query = {}

    # Handle text search across multiple fields
    if @text_terms.any?
      text_query = @text_terms.join(' ')
      query[:name_or_description_or_comments_content_or_tasks_description_cont] = text_query
    end

    # Handle field filters with more confidence now that we've whitelisted attributes
    @field_filters.each do |field, value|
      case field.downcase
      when 'state'
        query[:state_eq] = value
      when 'type'
        query[:story_type_eq] = value
      when 'label'
        query[:labels_name_in] = value.split(',')
      when 'owner'
        query[:owners_name_or_owners_username_cont] = value
      when 'requester'
        query[:requester_name_or_requester_username_cont] = value
      when 'attachment'
        query[:has_attachment] = true if value == 'true'
      when 'blocked'
        query[:has_blocker] = true if value == 'true'
      end
    end

    query
  end

  def build_epics_query
    query = {}

    if @text_terms.any?
      text_query = @text_terms.join(' ')
      query[:name_or_description_cont] = text_query
    end

    query
  end

  def build_labels_query
    query = {}

    if @text_terms.any?
      text_query = @text_terms.join(' ')
      query[:name_cont] = text_query
    end

    query
  end
end
