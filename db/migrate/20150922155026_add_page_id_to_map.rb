class AddPageIdToMap < ActiveRecord::Migration
  def change
    add_column :maps, :page_id, :string
    add_index :maps, :page_id, :unique => true
  end
end
