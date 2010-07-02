class AddSourceUrlToMapAndLayer < ActiveRecord::Migration
  def self.up
    add_column :maps, :source_uri, :string
    add_column :layers, :source_uri, :string
  end

  def self.down
    remove_column :maps, :source_uri
    remove_column :layers, :source_uri
  end
end
