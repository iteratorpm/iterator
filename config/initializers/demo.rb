Rails.application.configure do
  # Ensure a secret_key_base is always set
  if Rails.env.production?
    config.secret_key_base = ENV["SECRET_KEY_BASE"] || begin
      warn "[WARNING] No SECRET_KEY_BASE found, using temporary value for demo/testing"
      SecureRandom.hex(64)
    end
  end

  # Enable "demo mode" if SMTP is not configured
  smtp_configured = Rails.env.production? && ENV["SMTP_ADDRESS"].present? && ENV["SMTP_USER"].present?
  ENV["DEMO_MODE"] ||= smtp_configured ? "false" : "true"
end

# Auto-create a demo user in demo mode
if ENV["DEMO_MODE"] == "true" && defined?(User) && User.count.zero?
  Rails.logger.info "[Demo] Creating default user: demo@example.com / password"
  User.create!(
    email: "demo@example.com",
    password: "password",
    password_confirmation: "password",
    admin: true,
    confirmed_at: Time.now
  )
end
