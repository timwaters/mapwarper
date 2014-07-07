class AddUserIdToLayer < ActiveRecord::Migration
  def self.up
      add_column :layers, :user_id, :integer
  end

  def self.down
      remove_column :layers, :user_id
  end
end
