require 'geo_ruby'
require 'active_record'

include GeoRuby::SimpleFeatures

module SpatialAdapter
  #Translation of geometric data types
  def geometry_data_types
    {
      :point => { :name => "POINT" },
      :line_string => { :name => "LINESTRING" },
      :polygon => { :name => "POLYGON" },
      :geometry_collection => { :name => "GEOMETRYCOLLECTION" },
      :multi_point => { :name => "MULTIPOINT" },
      :multi_line_string => { :name => "MULTILINESTRING" },
      :multi_polygon => { :name => "MULTIPOLYGON" },
      :geometry => { :name => "GEOMETRY"}
    }
  end
end

require 'spatial_adapter/raw_geom_info'
require 'spatial_adapter/spatial_column'
require 'spatial_adapter/schema_definitions'
require 'spatial_adapter/schema_dumper'
require 'spatial_adapter/table_definition'
require 'spatial_adapter/adapters/postgis'
require 'spatial_adapter/adapters/mysql'
