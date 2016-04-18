require "#{ Rails.root }/lib/misc/gdalinfo.rb"
require "#{ Rails.root }/lib/misc/georuby_extension.rb"
require "#{ Rails.root }/lib/misc/postgis_database_tasks.rb" if Rails.env.test?
