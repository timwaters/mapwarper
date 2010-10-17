class AddSomeMoreMapMetadataFields < ActiveRecord::Migration
  def self.up
    add_column :maps, :date_depicted, :string, :limit => 4, :default => ""
    add_column :maps, :call_number, :string
  end

  def self.down
    remove_column :maps, :date_depicted
    remove_column :maps, :call_number
  end
end
