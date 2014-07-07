class CreateLayers < ActiveRecord::Migration
  def self.up
    create_table :layers do |t|
      t.string   :name
      t.text     :description
      t.string   :bbox
      t.integer  :owner
      t.timestamps
    end
  end

  def self.down
    drop_table :layers
  end
end
