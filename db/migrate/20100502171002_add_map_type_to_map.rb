class AddMapTypeToMap < ActiveRecord::Migration
  def self.up
    add_column :maps, :map_type, :integer
     Map.update_all("map_type = 1")
  end

  def self.down
    remove_column :maps, :map_type
  end
end

