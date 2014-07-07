class AddMapCountsToLayer < ActiveRecord::Migration
 def self.up
    add_column :layers, :maps_count, :integer, :default => 0
    add_column :layers, :rectified_maps_count, :integer, :default=> 0

  end

  def self.down
    remove_column :layers, :maps_count
    remove_column :layers, :rectified_maps_count
  end
end
