class AddImportReferenceToMap < ActiveRecord::Migration
  def self.up
    add_column :maps, :import_id, :integer
  end

  def self.down
    remove_column :maps, :import_id
  end
end
