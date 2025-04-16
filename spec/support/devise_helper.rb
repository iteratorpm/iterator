module ControllerMacros
  def login_admin
    let(:current_user) { create(:user, admin: true) }
    before(:each) do
      sign_in current_user
    end
  end

  def login_user
    let(:current_user) { create(:user) }
    before(:each) do
      sign_in current_user
    end
  end

end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Devise::Test::IntegrationHelpers, :type => :request
  config.extend ControllerMacros
end

