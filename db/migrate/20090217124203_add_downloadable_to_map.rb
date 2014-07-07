class AddDownloadableToMap < ActiveRecord::Migration
  def self.up
    	add_column :maps, :downloadable,  :boolean, :default => true
  end

  def self.down
     remove_column :maps,  :downloadable
  end
end
