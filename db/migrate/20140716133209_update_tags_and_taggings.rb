class UpdateTagsAndTaggings < ActiveRecord::Migration
  def up
    #taggings
    add_column :taggings, :context, :string, :limit => 128
    add_column :taggings, :tagger_id, :integer
    add_column :taggings, :tagger_type, :string

    remove_index :taggings, :tag_id

    add_index :taggings,
      [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
      unique: true, name: 'taggings_idx'
    
    add_column :tags, :taggings_count, :integer, default: 0
    
    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end
   
  end
  
  def down
    remove_column :taggings, :context
    remove_column :taggings, :tagger_id
    remove_column :taggings, :tagger_type
    
    remove_index :taggings, name: 'taggings_idx'
    add_index :taggings, :tag_id
    
    remove_column :tags, :taggings_count

  end
end
