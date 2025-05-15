module TurboValidations
  extend ActiveSupport::Concern

  included do
    helper_method :render_turbo_validation_errors
  end

  def render_turbo_validation_errors(resource)
    return unless resource.errors.present?

    render partial: "shared/validation_errors", locals: { resource: resource }, layout: false
  end
end
