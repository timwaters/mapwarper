class AddSpatialBboxGeomColumnToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :bbox_geom, :polygon
    add_index :maps, :bbox_geom, :spatial => true
    say "added column and index, now updating maps"
    Map.reset_column_information
    Map.find(:all).each do | map |
      map.update_bbox
      sleep(0.05)
    end
    say "all done!"
  end

  def self.down
    remove_column :maps, :bbox_geom
    remove_index :maps, :bbox_geom
  end
end

