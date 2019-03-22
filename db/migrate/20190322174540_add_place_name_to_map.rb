class AddPlaceNameToMap < ActiveRecord::Migration
  def change
    add_column :maps, :place_name, :string
  end
end
