class AddSpatialBboxGeomColumnToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :bbox_geom, :polygon, :srid => 4236
    add_index :maps, :bbox_geom, :spatial => true
  end

  def down
    remove_column :maps, :bbox_geom
    remove_index :maps, :bbox_geom
  end
  
end

