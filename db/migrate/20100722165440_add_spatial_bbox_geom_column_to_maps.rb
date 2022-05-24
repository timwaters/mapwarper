class AddSpatialBboxGeomColumnToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :bbox_geom, :st_polygon, :srid => 4236
    add_index :maps, :bbox_geom, :using => :gist
  end

  def down
    remove_column :maps, :bbox_geom
    remove_index :maps, :bbox_geom
  end
  
end

