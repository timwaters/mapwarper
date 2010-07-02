class AddExtraColumnsToMap < ActiveRecord::Migration
  def self.up
  	add_column :maps, :bbox, :string
  	add_column :maps, :publisher, :string
  	add_column :maps, :authors, :string
  	add_column :maps, :scale, :string

  	add_column :maps, :published_date, :datetime
  	add_column :maps, :reprint_date, :datetime
  end
  def self.down
  remove_column :maps,  :bbox
  remove_column :maps,  :publisher
  remove_column :maps,  :authors
  remove_column :maps,  :scale
  

  remove_column :maps,  :published_date
  remove_column :maps,  :reprint_date
  end
end
