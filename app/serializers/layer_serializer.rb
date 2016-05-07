class LayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :created_at, :updated_at, :bbox, :maps_count, :rectified_maps_count, :is_visible, :source_uri, :percentage
  

  link :kml do
    layer_url(:id => object.id, :format => :kml)
  end
  
  link :tiles do
    "http://warper.wmflabs.org/layers/tile/#{object.id}/{z}/{x}/{y}.png"
  end
  
  link :wms do
    wms_layer_url(:id=>object.id, :request => "GetCapabilities", :service => "WMS", :version => "1.1.1")
  end
  
 
end


