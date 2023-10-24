require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BookSearch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.autoload_paths << "#{Rails.root}/app/services"

    config.time_zone = 'Moscow'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locale', '*.{rb,yml}')]
    config.i18n.available_locales = [:ru, :en]
    config.i18n.default_locale = :ru

    # Remove ActionMailbox and ActiveStorage from routes
    initializer(:remove_action_mailbox_and_activestorage_routes, after: :add_routing_paths) { |app|
      app.routes_reloader.paths.delete_if {|path| path =~ /activestorage/}
      app.routes_reloader.paths.delete_if {|path| path =~ /actionmailbox/ }
    }

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'mailers'

    config.generators do |g|
      g.test_framework :rspec,
                       request_specs: false,
                       controller_specs: true,
                       view_specs: false,
                       routing_specs: false,
                       helper_specs: false
    end
  end
end
