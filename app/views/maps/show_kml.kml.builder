#this acts as a kml reflector, called from the show as 8978.kml for example
#thanks to Jason Birch messily ported from http://www.jasonbirch.com/wms2kml/wms2kml.phps

bbox =  @map.bounds
bounds = bbox.split(',')
west = bounds[0]
south = bounds[1]
east = bounds[2]
north = bounds[3]
width = 256
height = 256

wms_baseurl = "http://"+request.host_with_port+ url_for(:controller => "maps", :action=> "wms", :id=>@map)
this_baseurl = "http://"+request.host_with_port+ url_for(:controller => "maps", :action=> "show", :id=>@map, :format=>"kml")
xml.instruct! :xml
xml.kml(:xmlns => "http://www.opengis.net/kml/2.2") do
  #xml.NetworkLinkControl{
  #  xml.minRefreshPeriod(3600)
  #}
  xml.Document{

    if params[:DBOX]
      coords = params[:DBOX].split(',')
      west = coords[0].to_f
      south = coords[1].to_f
      east = coords[2].to_f
      north = coords[3].to_f
      drawOrder = coords[4].to_i
      baseurl = wms_baseurl + '?service=wms&VERSION=1.1.1&request=GetMap&srs=EPSG:4326&width='+width.to_s+'&height='+height.to_s+'&format=image/png&transparent=true&layers=image&styles='
      xml.Region {
        xml.Lod {
          xml.minLodPixels(128);
          xml.maxLodPixels(-1);
        }
        xml.LatLonBox{
          xml.north(north)
          xml.south(south)
          xml.east(east)
          xml.west(west)
        }
      }

      xml.GroundOverlay{
        xml.drawOrder(drawOrder)
        xml.Icon{
          url_to_use = baseurl+'&bbox='+west.to_s+','+south.to_s+','+east.to_s+','+north.to_s
          xml.href {
            xml.cdata!(url_to_use)
          }
        }
        xml.LatLonBox{
          xml.north(north)
          xml.south(south)
          xml.east(east)
          xml.west(west)
        }
      }
      xval =Array.new
      yval =Array.new
      xval[0] = west
      xval[1] = west - (west - east) / 2 
      xval[2] = east

      yval[0] = south
      yval[1] = south -(south - north) / 2
      yval[2] = north

      drawOrder += 1

      (0..1).each do |x|
        (0..1).each do |y|

          xml.NetworkLink {
            #xml.visibility(1)
            xml.Region{
              xml.LatLonAltBox{
              xml.north(yval[y+1])
              xml.south(yval[y])
              xml.east(xval[x+1])
              xml.west(xval[x])
            }
            xml.Lod{
              xml.minLodPixels(128)
              xml.maxLodPixels(-1)
            }
            }
            xml.Link{
              xml.viewRefreshMode("onRequest")
              xml.href{
                xml.cdata!(this_baseurl+'?DBOX='+xval[x].to_s+','+yval[y].to_s+','+xval[x+1].to_s+','+yval[y+1].to_s+','+drawOrder.to_s)
              }
            }
          }

        end
      end

    else
      #initial link full extent
      xml.name { xml.cdata!(@map.title) }
        xml.Style{
          xml.ListStyle{
          xml.listItemType("checkHideChildren")
        }
        }

        xml.NetworkLink {
          #xml.visibility(1)
          xml.Region{
            xml.LatLonAltBox{
            xml.north(north)
            xml.south(south)
            xml.east(east)
            xml.west(west)
          }
          xml.Lod{
            xml.minLodPixels(128)
            xml.maxLodPixels(-1)
          }
          }
          xml.Link{
            xml.viewRefreshMode("onRequest")
            xml.href(this_baseurl+'?DBOX='+west.to_s+','+south.to_s+','+east.to_s+','+north.to_s+",1")
          }
        }
    end
  }


end
