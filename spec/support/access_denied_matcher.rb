RSpec::Matchers.define :be_access_denied do
  match do |response|
    # Handles both redirect and non-HTML formats (like JSON)
    if response.redirect?
      response.location == Rails.application.routes.url_helpers.root_url(host: "http://www.example.com")
    else
      response.status == 404 || response.status == 403
    end
  end

  failure_message do |response|
    "expected response to be access denied (redirect to root or 404/403), but got #{response.status} and location #{response.location}"
  end
end
