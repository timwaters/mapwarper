# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  UserMailer::SITE_EMAIL = "ss@scc.com"
  UserMailer::SITE_NAME =  "tim"
  UserMailer::SITE_URL =  "http://www.example.com"
  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

class Hash

  # filter key out of a hash
  # {:a=>1, :b=> 2, :c=> 3}.except(:a)
  # results of hash after call {:b=> 2, :c=> 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  # override some keys with a new value
  # {:a=>1, :b=> 2, :c=> 3}.with(:a => 4)
  # results of hash after call {:a => 4, :b=> 2, c: => 3 }
  def with(overrides = {})
    self.merge overrides
  end

  # return a hash with only the pairs identified by the +keys+
  # { :a=>1, :b=>2, :c=>3}.only(:a)
  # results of hash after call {:a=>1}
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym ) }
  end

end

module NamedScopeSpecHelper

  class HaveNamedScope #:nodoc:

    def initialize(scope_name, options, proc_args=nil)
      @scope_name = scope_name.to_s
      @options = options
      @proc_args = proc_args
    end

    def matches?(klass)
      @klass = klass
      if @options.class == Proc
        @klass.send(@scope_name, *@proc_args).proxy_options.should === @options.call(*@proc_args)
      else
        @klass.send(@scope_name).proxy_options.should === @options
      end
      true
    end

    def failure_message
      "expected #{@klass} to define named scope '#{@scope_name}' with options #{@options.inspect}, but it didn't"
    end

    def negative_failure_message
      "expected #{@klass} to not define named scope '#{@scope_name}' with options #{@options.inspect}, but it did"
    end

  end

  def have_named_scope(scope_name, options, proc_args=nil)
    HaveNamedScope.new(scope_name, options, proc_args)
  end

end
