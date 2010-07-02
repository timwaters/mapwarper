require 'gdalinfo'

namespace :map do
  desc "Regenerates all bbox of all rectified maps"
  task(:regenbbox => :environment) do
    desc "updates extents for all map. May take a long time!"
    puts "Are you sure you want to continue? [y/N]"
    break unless STDIN.gets.match(/^y$/i)
    puts
    Map.warped.find(:all).each do |mapscan|
      next unless File.exists? mapscan.warped_filename
      puts mapscan.warped_filename
      begin
        mapscan.update_bbox
        sleep(0.05)
      rescue
      end
    end
  end
end
