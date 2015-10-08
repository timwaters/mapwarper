namespace :warper do
  namespace :wikimaps do
    desc 'Calls wikimedia Commons to update the pageid of maps'
    task(update_pageid: :environment) do
      puts 'This calls the wikimedia commons api and updates the pageid and image_url of maps which do not have one.'
      puts 'Are you sure you want to continure? [y/N]'
      break unless STDIN.gets.match(/^y$/i)

      site = 'https://commons.wikimedia.org'

      count = 0
      unknown = []
      
      maps = Map.all.where.not(unique_id: '').where('page_id is null  OR image_url is null')
      maps.each do |map|
        title = URI.decode map.unique_id
      #  uri = "#{site}/w/api.php?action=query&prop=info&format=json&titles=File:#{title}"
        uri = "#{site}/w/api.php?action=query&prop=imageinfo|info&iiprop=url&format=json&titles=File:#{title}"
        url = URI.parse(URI.encode(uri))

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        req = Net::HTTP::Get.new(URI.encode(uri))
        user_agent = "#{APP_CONFIG['site']} (Update PageID Rake Script) (https://commons.wikimedia.org/wiki/Commons:Wikimaps)"
        req.add_field('User-Agent', user_agent)

        resp = http.request(req)

        body = JSON.parse(resp.body)
        
        if body['query']['pages'].keys.size == 1
          pageid = body['query']['pages'].keys.first
          
          if pageid != '-1'
            map.page_id = pageid
            image_url =  body['query']['pages'][pageid]['imageinfo'][0]['url']
            map.image_url = image_url
            
            puts "saving Map:#{map.id} pageid:#{pageid} image_url:#{image_url}" 
            
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
