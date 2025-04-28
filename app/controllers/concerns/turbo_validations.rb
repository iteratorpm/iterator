module TurboValidations
  extend ActiveSupport::Concern

  included do
    helper_method :render_turbo_validation_errors
  end

  def render_turbo_validation_errors(resource)
    return unless resource.errors.present?

    render turbo_stream: turbo_stream.replace(
      "modal",
      partial: "shared/validation_errors",
      locals: { resource: resource }
    )
  end
end
