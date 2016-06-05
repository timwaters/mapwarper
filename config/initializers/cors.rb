module YourApp
  class Application < Rails::Application
    config.middleware.use Rack::Cors do
      allow do
        origins 'localhost:8000'
        resource '/api/*',
          :headers => :any,
          :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :methods => [:get, :post, :options, :delete, :put]
      end
    end
  end
end