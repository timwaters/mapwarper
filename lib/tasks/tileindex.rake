namespace :layer do
    desc "makes tileindex for all visible layers and gets the bounds for the layer. affects ALL layers. p"
    task(:updatetileindex => :environment) do
    puts "(Re)creating tileindex for all layers"
    puts "only affects visible layers, i.e. those where is_visible => true"
    puts "and only layers which have rectified maps within them"
    puts "also updates the counts for the maps"
    puts "This may slow down the server"
    puts "Are you sure you want to continure? [y/N]"
    break unless STDIN.gets.match(/^y$/i)
    puts
    count = 0
    layers = Layer.visible.find :all
    layers.each do |layer|
      layer.update_counts
      if layer.rectified_maps_count > 0
        layer.update_layer
        #sleep(0.2)
        #print '.'
        puts " #{layer.id}"
        $stdout.flush
        count += 1
      end
        sleep(0.2)
      end 
    puts "\n Count = #{count} layers done"
    end
end
