Bakaba::Application.configure do

  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = true
  config.assets.precompile += %w( burichan.css futaba.css gurochan.css photon.css pages.css )
  config.assets.digest = true
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  Paperclip.options[:command_path] = "/usr/bin"

end
