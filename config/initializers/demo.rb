Rails.application.configure do
  # Ensure a secret_key_base is always set
  config.secret_key_base = ENV["SECRET_KEY_BASE"] || begin
    warn "[WARNING] No SECRET_KEY_BASE found, using temporary value for demo/testing"
    SecureRandom.hex(64)
  end

  # Enable "demo mode" if SMTP is not configured
  smtp_configured = ENV["SMTP_ADDRESS"].present? && ENV["SMTP_USER"].present?
  ENV["DEMO_MODE"] ||= smtp_configured ? "false" : "true"
end

# Toggle Devise confirmable based on SMTP presence
Devise.setup do |config|
  if ENV["DEMO_MODE"] == "true"
    config.reconfirmable = false
  end
end

# Monkey patch Devise's :confirmable setup on User model
ActiveSupport.on_load(:active_record) do
  require_dependency Rails.root.join("app/models/user.rb")

  if ENV["DEMO_MODE"] == "true"
    User.devise_modules.delete(:confirmable) if User.devise_modules.include?(:confirmable)
  else
    User.devise_modules << :confirmable unless User.devise_modules.include?(:confirmable)
  end
end

# Auto-create a demo user in demo mode
if ENV["DEMO_MODE"] == "true" && defined?(User) && User.count.zero?
  Rails.logger.info "[Demo] Creating default user: demo@example.com / password"
  User.create!(
    email: "demo@example.com",
    password: "password",
    password_confirmation: "password",
    confirmed_at: Time.now
  )
end
