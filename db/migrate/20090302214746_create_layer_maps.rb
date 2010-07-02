class CreateLayerMaps < ActiveRecord::Migration
  def self.up
    
    create_table :layers_maps, :id => false do |t|
      t.references :layer, :map
      t.timestamps
    end
    
    add_index :layers_maps, [:map_id]
    add_index :layers_maps, [:layer_id]
  end

  def self.down

    drop_table :layers_maps
  end
end
