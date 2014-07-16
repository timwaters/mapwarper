require "#{ Rails.root }/lib/enum_fu/lib/enum_fu.rb"
ActiveRecord::Base.send :include, EnumFu