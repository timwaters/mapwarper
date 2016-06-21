class MapSerializer < ActiveModel::Serializer
  has_many :layers
  belongs_to :owner, :class_name => "User",  :key => :added_by
  attributes  :id, :title, :description, :width, :height, :status,:mask_status, :created_at, :updated_at, :bbox, :map_type, :source_uri, :unique_id, :page_id, :date_depicted, :image_url, :thumb_url
  
  link(:self) {     api_v1_map_url(object) }
  
  link(:gcps_csv) { gcps_map_url(:id =>object.id, :format=>:csv) }
  link(:mask) {     masking_map_url(:id => object.id)}
  link(:geotiff) {  export_map_url(:id => object.id, :format => :tif) }
  link(:png) {      export_map_url(:id => object.id, :format => :png)}
  link(:aux_xml){   export_map_url(:id => object.id, :format => :aux_xml) }
  link(:kml) {      map_url(:id => object.id, :format => :kml)}
  link(:tiles){    "#{tile_map_base_url(:id => object.id)}/{z}/{x}/{y}.png" }
  link(:wms) {      wms_map_url(:id=>object.id, :request => "GetCapabilities", :service => "WMS", :version => "1.1.1")}
  
  class LayerSerializer < ActiveModel::Serializer
    attributes  :name, :description
    link(:self) { api_v1_layer_url(object) }
  end
  
  class UserSerializer < ActiveModel::Serializer
    attributes :login
  end
 
end
