xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
xml.channel do
  xml.title t('.feed_title') + @tags.to_s
  xml.description t('.feed_description')+ @tags
  xml.link tag_maps_url(:id=>@tags)
  for map in @maps

    xml.item do
        xml.title map.title
        xml.description map.description
        xml.pubDate map.created_at.to_s(:rfc822)
        xml.link map_url(map)
        xml.guid
      end

    end
  end
end
