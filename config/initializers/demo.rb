Rails.application.configure do
  # Ensure a secret_key_base is always set
  if Rails.env.production?
    config.secret_key_base = ENV["SECRET_KEY_BASE"] || begin
      warn "[WARNING] No SECRET_KEY_BASE found, using temporary value for demo/testing"
      SecureRandom.hex(64)
    end
  end
end
