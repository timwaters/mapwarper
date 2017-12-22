class AddProtectToMap < ActiveRecord::Migration
  def change
    add_column :maps, :protect, :boolean, default: false
  end
end
