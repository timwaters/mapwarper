class AddGcpTouchedAtAndLastRectifiedToMap < ActiveRecord::Migration
  def self.up
    add_column :maps, :rectified_at, :datetime
    add_column :maps, :gcp_touched_at, :datetime
  end

  def self.down
    remove_column :maps, :rectified_at
    remove_column :maps, :gcp_touched_at
  end
end
