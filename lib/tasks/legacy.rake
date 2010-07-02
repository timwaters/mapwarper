namespace :legacy do
  desc "Migrate legacy data"
  task :migrate => :environment do
    require 'db/legacy/legacyBase'
    require 'db/legacy/legacyMap'
    require 'db/legacy/legacyGcp'

    puts 'Migrating mapscans to maps.'
    puts
    puts "WARNING: This will transfer old mapscans in another database to this database, run with RAILS_ENV=production or something"
    puts "Also, you should open up this rake file and alter some of the parameters before starting."
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)
    puts

    # You can pass values from the command line rake call (e.g. rake legacy:migrate MODEL=LegacyUser START_ROW=500)
    # as a hash to your migration script using the ENV variable
    LegacyMap.migrate_all

    puts "Migrating GCPS"
    #You can also migrate the GCPs using some simple sql: insert into gcps select * from geowarp_development.gcps'
    LegacyGcp.migrate_all
    puts "done"
  end
end
