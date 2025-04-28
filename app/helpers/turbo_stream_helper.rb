module TurboStreamHelper
  def render_validation_errors(resource)
    render "shared/validation_errors_stream", resource: resource
  end
end
