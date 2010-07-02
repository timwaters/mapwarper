class CreateUserMaps < ActiveRecord::Migration
  def self.up
    create_table :my_maps do  |t|
      t.integer :map_id
      t.integer :user_id
      t.timestamps
    end
    add_index :my_maps, [:map_id, :user_id], :unique =>true
    add_index :my_maps, :map_id
  end

  def self.down
    remove_index :my_maps, :map_id
    remove_index :my_maps, [:map_id, :user_id]
    drop_table :my_maps
  end
end
