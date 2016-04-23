ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods 
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  Map.auditing_enabled = false
  Gcp.auditing_enabled = false

  Object.send(:remove_const, :SRC_MAPS_DIR)
  Object.const_set("SRC_MAPS_DIR", File.join(Rails.root, "/test/fixtures/data/"))
  Object.send(:remove_const, :DST_MAPS_DIR)
  Object.const_set("DST_MAPS_DIR", File.join(Rails.root, "/test/fixtures/data/"))
  
  Object.send(:remove_const, :TILEINDEX_DIR)
  Object.const_set("TILEINDEX_DIR", File.join(Rails.root, "/test/fixtures/data/"))

  Paperclip::Attachment.default_options[:path] = "#{Rails.root}/test/test_files/:class/:id_partition/:style.:extension"
end
