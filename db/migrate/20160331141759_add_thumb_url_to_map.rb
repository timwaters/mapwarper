class AddThumbUrlToMap < ActiveRecord::Migration
  def change
    add_column :maps, :thumb_url, :text
  end
end
