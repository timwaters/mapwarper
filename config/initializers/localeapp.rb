require 'localeapp/rails'

if defined? APP_CONFIG['localeapp_api_key'] 
  key = APP_CONFIG['localeapp_api_key']
else
  key = ENV['LOCALEAPP_API_KEY']
end

Localeapp.configure do |config|
  config.sending_environments = []
  config.reloading_environments = []
  config.polling_environments = []
  config.api_key = key
end
