class AddExtraMetadataFieldsToMap < ActiveRecord::Migration
  def self.up
     add_column :maps, :publication_place, :string
     add_column :maps, :subject_area, :string
     add_column :maps, :unique_id, :string
     add_column :maps, :metadata_projection, :string
     add_column :maps, :metadata_lat, :decimal, :precision => 15, :scale => 10
     add_column :maps, :metadata_lon, :decimal, :precision => 15, :scale => 10
  end

  def self.down
     remove_column :maps, :publication_place
     remove_column :maps, :subject_area
     remove_column :maps, :metadata_unique_id
     remove_column :maps, :metadata_projection
     remove_column :maps, :metadata_lat
     remove_column :maps, :metadata_lon
  end
end
