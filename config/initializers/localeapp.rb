require 'localeapp/rails'

Localeapp.configure do |config|
  config.sending_environments = []
  config.reloading_environments = []
  config.polling_environments = []
  config.api_key = APP_CONFIG['localeapp_api_key']
end
