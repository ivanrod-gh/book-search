ActiveModelSerializers.config.adapter = :json
Oj.optimize_rails
ActiveSupport::Notifications.unsubscribe(ActiveModelSerializers::Logging::RENDER_EVENT)
