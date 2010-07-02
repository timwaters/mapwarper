class AddMapCountsToLayer < ActiveRecord::Migration
 def self.up
    add_column :layers, :maps_count, :integer, :default => 0
    Layer.reset_column_information
    def Layer.readonly_attributes; nil end #evil hack

    Layer.find(:all).each do |l|
      l.maps_count = l.maps.count
      l.save!
    end

    add_column :layers, :rectified_maps_count, :integer, :default=> 0
    Layer.reset_column_information
    def Layer.readonly_attributes; nil end #evil hack
    Layer.find(:all).each do |l|
      l.rectified_maps_count = l.maps.count(:conditions => ["status = 4"])
      l.save!
    end
  end

  def self.down
    remove_column :layers, :maps_count
    remove_column :layers, :rectified_maps_count
  end
end
