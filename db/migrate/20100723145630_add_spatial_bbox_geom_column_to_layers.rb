class AddSpatialBboxGeomColumnToLayers < ActiveRecord::Migration
 def self.up
    add_column :layers, :bbox_geom, :polygon
    add_index :layers, :bbox_geom, :spatial => true
    Layer.reset_column_information
    say "Now updating the bounding boxes for all layers"
    Layer.find(:all).each do | layer |
      layer.set_bounds
      sleep(0.05)
    end
    say "all done"
  end

  def self.down
    remove_column :layers, :bbox_geom
    remove_index :layers, :bbox_geom
  end
end
