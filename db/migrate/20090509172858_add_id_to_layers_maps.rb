class AddIdToLayersMaps < ActiveRecord::Migration
  def self.up
    add_column :layers_maps, :id, :primary_key
  end

  def self.down
     remove_column :layers_maps, :id
  end
end
