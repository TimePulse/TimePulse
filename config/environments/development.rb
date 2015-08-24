TimePulse::Application.configure do
  #config.middleware.use 'Insight::App',
    #:secret_key => '7370ca22d6be47dd8392a54db32a64a9d2cfb030e698e50252a7682da89de2e5aa80488f6bf73d3d8b1cf7939468774382739c56c3d687d326780bdbe53c899f',
    #:panel_files => %w[rails_info_panel timer_panel request_variables_panel cache_panel templates_panel log_panel memory_panel speedtracer_panel]
  # Settings specified here will take precedence over those in
  # config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

  config.action_controller.perform_caching = false #true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # config.logical_authz.debug!

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end
