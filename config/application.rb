require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cfb25DynastyTrackerBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.middleware.use ActionDispatch::Cookies
    Rails.application.config.middleware.use ActionDispatch::Session::CookieStore, 
      key: "_dynasty_tracker_session", 
      same_site: :lax, 
      secure: false

    Rails.application.config.session_store :cookie_store, 
      key: "_dynasty_tracker_session", 
      same_site: :lax, 
      secure: false

    config.action_dispatch.cookies_same_site_protection = :none

    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins(
          Rails.env.development? ? 'http://localhost:5173' : 'https://cfb-dynasty-tracker.netlify.app'
        )
        resource '*',
                 headers: :any,
                 methods: [:get, :post, :put, :patch, :delete, :options, :head],
                 credentials: true
      end
    end

  end
end
