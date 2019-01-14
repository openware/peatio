# encoding: UTF-8
# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require the plugins listed in config/plugins.yml.
require_relative 'plugins'

module Peatio
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Adding Grape API
    # Eager loading all app/ folder
    config.eager_load_paths += Dir[Rails.root.join('app')]

    # Configure Sentry as early as possible.
    if ENV['SENTRY_DSN_BACKEND'].present?
      require 'sentry-raven'
      Raven.configure { |config| config.dsn = ENV['SENTRY_DSN_BACKEND'] }
    end

    # Require Scout.
    require 'scout_apm' if Rails.env.in?(ENV['SCOUT_ENV'].to_s.split(',').map(&:squish))

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV.fetch('TIMEZONE')

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[root.join('config', 'locales', '*.{yml}')]
    config.i18n.available_locales = ['en']

    # Configure relative url root by setting URL_ROOT_PATH environment variable.
    # Used by workbench with API Gateway.
    config.relative_url_root = ENV.fetch('URL_ROOT_PATH', '/')

    config.assets.initialize_on_precompile = true

    # Automatically load and reload constants from "lib/*":
    #   lib/aasm/locking.rb => AASM::Locking
    # We disable eager load here since lib contains lot of stuff which is not required for typical app functions.
    config.paths.add 'lib', eager_load: false, autoload: true

    # Remove cookies and cookies session.
    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Session::CookieStore

    # Disable CSRF.
    config.action_controller.allow_forgery_protection = false

    config.middleware.use ActionDispatch::Flash

  end
end
