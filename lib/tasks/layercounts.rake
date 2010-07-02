namespace :layer do
    desc "updates counts for layers"
    task(:updatecounts => :environment) do
    puts "also updates the counts for the maps"
    puts "Are you sure you want to continure? [y/N]"
    break unless STDIN.gets.match(/^y$/i)
    puts
    count = 0
    layers = Layer.find :all
    layers.each do |layer|
      layer.update_counts
        puts " #{layer.id}"
        $stdout.flush
        count += 1
        sleep(0.1)
      end 
    puts "\n Count = #{count} layers done"
    end
end
