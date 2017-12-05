class AddMapCounterAndFilesizesToUser < ActiveRecord::Migration
  def change
    add_column :users, :own_maps_count, :integer
    add_column :users, :upload_filesize_sum, :integer
  end
end
