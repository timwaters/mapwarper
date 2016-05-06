class MapSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :width, :height, :status,:mask_status, :created_at, :updated_at, :bbox, :map_type, :source_uri, :unique_id, :page_id, :date_depicted, :image_url, :thumb_url
  
  link :mask do
    masking_map_url(:id => object.id)
  end
  
  link :geotiff do
    export_map_url(:id => object.id, :format => :tif) 
  end
  
  link :png do
    export_map_url(:id => object.id, :format => :png)
  end
  
  link :aux_xml do
    export_map_url(:id => object.id, :format => :aux_xml)
  end
  
  link :kml do
    map_url(:id => object.id, :format => :kml)
  end
  
  link :tiles do
    "http://warper.wmflabs.org/maps/tile/#{object.id}/{z}/{x}/{y}.png"
  end
  
  link :wms do
    wms_map_url(:id=>object.id, :request => "GetCapabilities", :service => "WMS", :version => "1.1.1")
  end
  
 
end


