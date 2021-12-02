class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.text :body
      t.geometry :geom
      t.references :map
      t.references :user

      t.timestamps null: false
    end
  end
end
