class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column "name", :string
      t.column "description", :text
      t.column "creator_id", :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
