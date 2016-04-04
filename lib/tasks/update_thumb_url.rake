namespace :warper do
  namespace :wikimaps do
    desc 'Calls wikimedia Commons to update the thumb_url of maps'
    task(update_thumb_url: :environment) do

      site = APP_CONFIG['omniauth_mediawiki_site']
      
      puts "This calls the wikimedia commons API and updates the thumb_url of maps which do not have one"
      puts "target wiki = #{site}"
      puts "Are you sure you want to continue? [y/N]"
      break unless STDIN.gets.match(/^y$/i)

      count = 0
      unknown = []
      maps = Map.all.where("page_id is not null").where("thumb_url = '' OR thumb_url IS NULL")
      maps.each do | map |
        uri = URI.encode(site + '/w/api.php?action=query&prop=imageinfo&iiprop=url&iiurlwidth=100&format=json&pageids=' + map.page_id.to_s)
      
        url = URI.parse(uri)
        http = Net::HTTP.new(url.host, url.port)
        if url.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        req = Net::HTTP::Get.new(URI.encode(uri))
        user_agent = "#{APP_CONFIG['site']} (Update thumb_url Rake Script) (https://commons.wikimedia.org/wiki/Commons:Wikimaps)"
        req.add_field('User-Agent', user_agent)
        resp = http.request(req)
      
        json = JSON.parse(resp.body)
        puts json.inspect  
        if json['query']['pages']["#{map.page_id}"]['imageinfo'].nil?
          puts "no image found for that pageid"
          unknown << map.page_id
          next
        end

        thumb_url = json['query']['pages']["#{map.page_id}"]['imageinfo'][0]['thumburl']
    
        puts "saving Map:#{map.id} pageid:#{map.page_id} thumb_url:#{thumb_url}" 
        map.update(:thumb_url => thumb_url)
        count += 1

      end
    
      puts "\n #{count} Maps updated"
      puts "\n #{unknown.size} maps had troubles"
      puts unknown.inspect

    end #task
  end #wikmaps
end #warper
      
