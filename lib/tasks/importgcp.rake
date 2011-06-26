require 'fastercsv'

namespace :import do
  desc "Imports GCP from a CSV file"
  task :gcps_from_csv => :environment do

    filename = "/home/tim/this.csv"
    puts "This imports a load of points from a csv file."
    puts "WARNING: This may bugger up the system, especially if you have a lot of points!"
    puts "Using File #{filename}"
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)


    data = open(filename)
    points = FasterCSV.parse(data, :headers => true, :header_converters => :symbol, :col_sep => ",")
    points.by_row!
    p "Preparing to insert points! "
    count = 0
    dup_count = 0
    points.each do | point |
      if point.size > 0
        map_id = Map.find_by_upload_file_name(point[:filename]).id.to_i
        gcp_conditions = {:x => point[:x].to_f, :y => point[:y].to_f, :lat => point[:lat].to_f, :lon => point[:lon].to_f, :map_id => map_id}
        unless Gcp.exists?(gcp_conditions)
          gcp = Gcp.new(gcp_conditions )
          gcp.save
          print '.'
          count+=1
        else
          dup_count+=1
          print '-'
          #Gcp.delete_all(gcp_conditions)
        end
      end
    end
    p "BOOM! Payload delivered! #{count} Points added. (#{dup_count} dups)."
  end
end