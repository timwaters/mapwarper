class CreateGcps < ActiveRecord::Migration
  def self.up
    create_table :gcps do |t|
			 		t.column :map_id, :integer
          t.column :x, :float
          t.column :y, :float
          t.column :lat, :decimal, :precision => 15, :scale => 10
          t.column :lon, :decimal, :precision => 15, :scale => 10  
      t.timestamps
    end
  end

  def self.down
    drop_table :gcps
  end
end
