class AddPhotoUuidToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :photo_uuid, :string
  end
end
