xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
xml.channel do
  xml.title "Feed of Warper Maps tagged with " + @tags.to_s
  xml.description "Maps tagged with "+ @tags
  xml.link map_tag_url(:id=>@tags)
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
