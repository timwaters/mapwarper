class AddCachePostTagListToMap < ActiveRecord::Migration
def self.up
      add_column :maps, :cached_tag_list, :string
    end


  def self.down
    remove_column :maps, :cached_tag_list
  end
end
