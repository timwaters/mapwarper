source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.5'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '3.0.1'  #loads jquery ui v 1.9.2
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc


gem "rack", ">= 1.6.12"


# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise', ">= 4.7.3"
gem 'devise-encryptable'

gem 'oauth', ">= 0.5.8"

gem 'omniauth-twitter'
gem 'omniauth-osm'
gem 'omniauth-github'
gem 'omniauth-mediawiki'
gem 'omniauth-facebook'

gem 'omniauth-rails_csrf_protection', '~> 0.1.2'

gem 'pg', '~>0.21'

gem 'activerecord-postgis-adapter', '~>3.0'

gem 'acts-as-taggable-on', '~> 3.5.0'
gem 'paperclip', '~> 5.3.0'
gem 'acts_as_commentable'
gem 'will_paginate', '~> 3.0'
gem 'spawnling', '~>2.1'

#Rails 4 support for the audited (acts_as_audited gem) is not quite rails4 worthy - see #https://github.com/collectiveidea/audited/pull/166
#gem 'audited-activerecord', github: 'timwaters/audited', branch: 'rails4'
gem 'audited-activerecord', '~> 4'

gem 'georuby'

gem 'actionpack-action_caching', git: 'http://github.com/timwaters/actionpack-action_caching', branch: 'feature/take_format_from_request'
gem 'redis-rails', '~> 5'

gem "rails-i18n"

gem 'pg_search'

gem 'rails-api'
gem 'active_model_serializers', git: 'http://github.com/rails-api/active_model_serializers', tag: 'v0.10.5'
gem 'simple_token_authentication', '~> 1.0'
gem 'rack-cors', :require => 'rack/cors'

gem "redcarpet", ">= 3.5.1"
gem "nokogiri", ">= 1.10.10"
gem 'mimemagic', '~> 0.3.10'

group :development do
   gem 'web-console', '~> 2.0'
  # gem 'spring'
   gem 'thin'
   gem 'capistrano', '~> 3.2.1'
   gem 'capistrano-rails',    :require => false
   gem 'capistrano-bundler',  :require => false
   gem 'rvm1-capistrano3',    :require => false
   gem 'i18n-tasks', '~> 0.9.6'
  # gem 'localeapp'
end

group :test do
  gem 'mocha'
  gem 'factory_girl_rails'
  gem 'webmock'
end
