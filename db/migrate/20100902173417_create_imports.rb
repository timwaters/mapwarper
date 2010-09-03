class CreateImports < ActiveRecord::Migration
  def self.up
    create_table :imports do |t|
      t.column "path", :string
      t.column "name", :string
      t.column "layer_title", :string
      t.column "map_title_suffix", :string
      t.column "map_description", :string
      t.column "map_publisher", :string
      t.column "map_author", :string
      t.column "path", :string
      t.column "state", :string
      t.column "layer_id", :integer
      t.column "uploader_user_id", :integer
      t.column "user_id", :integer
      t.column "file_count", :integer
      t.column "imported_count", :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :imports
  end
end
