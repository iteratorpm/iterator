
RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  # optional: make sure time is reset after each test
  config.after do
    travel_back
  end
end
