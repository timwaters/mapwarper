class AddFieldsForPlacingStepsToMap < ActiveRecord::Migration
  def self.up
    add_column :maps, :rough_lat, :decimal, :precision => 15, :scale => 10
    add_column :maps,  :rough_lon, :decimal, :precision => 15, :scale => 10
    
    add_column :maps, :rough_centroid, :point
    add_index :maps, :rough_centroid, :spatial => true

    add_column :maps, :rough_zoom, :integer
    add_column :maps, :rough_state, :integer
  end

  def self.down
    remove_column :maps, :rough_lat
    remove_column :maps, :rough_lon

    remove_index :maps, :rough_centroid
    remove_column :maps, :rough_centroid
   

    remove_column :maps, :rough_zoom
    remove_column :maps, :rough_state

  end
end
