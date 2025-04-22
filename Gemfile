source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "cancancan"
gem "devise"
gem 'slim'
gem "oj"
gem "ultimate_turbo_modal"
gem 'inline_svg'
gem "chartkick"
gem "chart-js-rails"
gem 'ransack'
gem 'redcarpet'
gem 'validate_url'
gem 'discard', '~> 1.4'
gem 'groupdate'

gem 'data_migrate'

gem "mission_control-jobs"
gem 'fast_blank'
gem 'kramdown'
gem 'paper_trail'
gem "cocoon"

group :development, :test do
  gem "amazing_print"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem 'rspec-rails', '~> 7.0.0'

  gem 'factory_bot_rails'

  gem "hotwire-spark"

  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-nav'

  gem 'pry-rails' # Causes rails console to open pry. `DISABLE_PRY_RAILS=1 rails c` can still open with IRB
  gem 'pry-rescue' # Start a pry session whenever something goes wrong.
  gem 'pry-theme' # An easy way to customize Pry colors via theme files

  gem "binding_of_caller"
  gem "ruby-lsp-rails"
  gem "ruby-lsp-rspec", require: false

  gem 'faker'
  gem 'rails-controller-testing'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "letter_opener"

  gem "bullet"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring"
  gem 'spring-commands-rspec'

  gem "better_errors"

  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'rack-mini-profiler'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  gem 'database_cleaner'
end
