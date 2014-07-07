class AddOwnerToMap < ActiveRecord::Migration
  def self.up
    add_column :maps, :owner_id, :integer
  end

  def self.down
    remove_column :maps, :owner_id
  end
end
