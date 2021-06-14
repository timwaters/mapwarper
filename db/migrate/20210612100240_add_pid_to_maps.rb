class AddPidToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :pid, :string
  end
end
