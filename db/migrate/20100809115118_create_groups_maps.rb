class CreateGroupsMaps < ActiveRecord::Migration
  def self.up
    create_table :groups_maps do |t|
      t.references :group, :map
      t.timestamps
    end
    add_index :groups_maps, [:map_id, :group_id], :unique =>true
    add_index :groups_maps, :map_id
  end

  def self.down
    drop_table :groups_maps
  end
end
