require "#{ Rails.root }/lib/misc/gdalinfo.rb"

namespace :warper do
  desc "Regenerates all bbox of all rectified maps"
  task(:map_regenbbox => :environment) do
    desc "updates extents for all map. May take a long time!"
    puts "Are you sure you want to continue? [y/N]"
    break unless STDIN.gets.match(/^y$/i)
    puts
    Map.warped.each do |mapscan|
      next unless File.exists? mapscan.warped_filename
      puts mapscan.warped_filename
      begin
        mapscan.update_bbox
        sleep(0.05)
      rescue Exception => e
        puts e.inpect
      end
    end
  end
end
