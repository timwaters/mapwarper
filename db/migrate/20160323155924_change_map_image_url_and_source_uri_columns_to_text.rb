class ChangeMapImageUrlAndSourceUriColumnsToText < ActiveRecord::Migration
  def change
    change_column :maps, :image_url, :text
    change_column :maps, :source_uri, :text
  end
end
