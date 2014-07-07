class AddDepictsYearToLayer < ActiveRecord::Migration
  def self.up
     add_column :layers, :depicts_year, :string, :limit => 4, :default => ""
  end

  def self.down
    remove_column :layers, :depicts_year
  end
end
