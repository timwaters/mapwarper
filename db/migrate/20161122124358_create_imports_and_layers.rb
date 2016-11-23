class CreateImportsAndLayers < ActiveRecord::Migration
  def change
    create_table :imports_layers do |t|
      t.belongs_to :import, index: true
      t.belongs_to :layer, index: true 
    end
  end
end
