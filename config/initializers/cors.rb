module Rails4Mapwarper
  class Application < Rails::Application
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '/api/*',
          :headers => :any,
          :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :methods => [:get, :post, :options, :delete, :put, :patch]
        resource '*/wms/*',
          :headers => :any,
          :methods => [:get, :options]
        resource '*/tile/*',
          :headers => :any,
          :methods => [:get, :options]
      end
    end
  end
end


