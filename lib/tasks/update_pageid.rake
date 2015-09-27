namespace :warper do
  namespace :wikimaps do
    desc 'Calls wikimedia Commons to update the pageid of maps'
    task(update_pageid: :environment) do
      puts 'this calls the wikimedia commons api and updates the pageid of maps which do not have one.'
      puts 'Are you sure you want to continure? [y/N]'
      break unless STDIN.gets.match(/^y$/i)

      site = 'https://commons.wikimedia.org'

      count = 0
      unknown = []
      maps = Map.all.where.not(unique_id: '').where(:page_id => nil )
      maps.each do |map|
        title = URI.decode map.unique_id
        uri = "#{site}/w/api.php?action=query&prop=info&format=json&titles=File:#{title}"
        url = URI.parse(URI.encode(uri))

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        req = Net::HTTP::Get.new(URI.encode(uri))
        req.add_field('User-Agent', 'WikiMaps Warper Update PageID Script by User:Chippyy chippy2005@gmail.com development')

        resp = http.request(req)

        body = JSON.parse(resp.body)
        body['query']['pages']
        if body['query']['pages'].keys.size == 1
          pageid = body['query']['pages'].keys.first

          if pageid != '-1'
            map.page_id = pageid
            puts "saving"
            puts map.inspect
            puts pageid
            map.save
            count += 1
          else
            puts "unknown"
            unknown << map
          end
        else
          puts 'Error: More than one result found for this'
          puts map.inspect
          puts body.inspect
        end
      end
      puts "\n Count = #{count} maps done"
      puts "\n #{unknown.size} maps unknown " unless unknown.empty?
      puts unknown.inspect unless unknown.empty?
       
    end
  end
end
