class AddImageUrlToMap < ActiveRecord::Migration
  def change
    add_column :maps, :image_url, :string
  end
end
