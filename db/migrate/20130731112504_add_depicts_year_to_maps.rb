class AddDepictsYearToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :depicts_year, :string
  end

  def self.down
    remove_column :maps, :depicts_year
  end
end
