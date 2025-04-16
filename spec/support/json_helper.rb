module JsonHelper
  def json_response
    @json ||= Oj.load response.body
  end
end

RSpec.configure do |config|
  config.include JsonHelper
end
