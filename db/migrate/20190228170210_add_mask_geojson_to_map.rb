class AddMaskGeojsonToMap < ActiveRecord::Migration
  def change
    add_column :maps, :mask_geojson, :text
  end
end
