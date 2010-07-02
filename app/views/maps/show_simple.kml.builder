xml.instruct! :xml
xml.kml(:xmlns => "http://www.opengis.net/kml/2.2") do
  xml.Folder {
    xml.open(1)
    xml.name("Map Warper #{@map.title.to_xs}" )
    xml.description("Containing warped images and maps.")
    xml.GroundOverlay {
      xml.name(@map.title.to_xs)
      xml.description(@map.description.to_xs)
      xml.Icon{
        xml.href("http://#{request.host_with_port}/#{@map.public_warped_png_url}")
      }
      xml.LatLonBox{
        bounds = @map.bounds.split(',')
        #TODO these are wrong way arounda
        xml.north(bounds[3])
        xml.south(bounds[1])
        xml.east(bounds[2])
        xml.west(bounds[0])
        xml.rotation(0)
      }
    } 
  }
end
