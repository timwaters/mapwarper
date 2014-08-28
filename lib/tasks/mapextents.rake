require "#{ Rails.root }/lib/misc/gdalinfo.rb"

namespace :warper do
  desc "updates extents for map if it hasnt got a proper bounding box"
  task(:map_updatebbox => :environment) do
    desc "updates extents for maps"
    puts "Are you sure you want to continue? [y/N]"
    break unless STDIN.gets.match(/^y$/i)
    puts
    Map.all.each do |mapscan|
      next if mapscan.bbox
      next unless File.exists? mapscan.warped_filename
      puts mapscan.warped_filename
      begin
        bbox = get_raster_extents mapscan.warped_filename
        mapscan.bbox = bbox.join ","
        mapscan.save 
      rescue
      end
    end
  end
end
