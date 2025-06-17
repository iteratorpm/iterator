if ENV["ADMIN"].present?
  email, password = ENV["ADMIN"].split(":", 2)

  if email && password
    admin = User.find_or_initialize_by(email: email)
    if admin.new_record?
      admin.password = password
      admin.name = email.split("@").first
      admin.username = admin.name
      admin.admin = true
      admin.confirmed_at = Time.now
      admin.save!
      Rails.logger.info "✅ Admin user created: #{email}"
    else
      Rails.logger.info "ℹ️ Admin user already exists: #{email}"
    end
  else
    Rails.logger.warn "⚠️ Invalid ADMIN format. Expected 'email:password'"
  end
end
