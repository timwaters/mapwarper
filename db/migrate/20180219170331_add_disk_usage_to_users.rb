class AddDiskUsageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disk_usage, :bigint
  end
end
