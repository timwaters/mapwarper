class UpgradeTaggingContext < ActiveRecord::Migration
  def up
    ActsAsTaggableOn::Tagging.all.each {|t| t.update_attribute :context, 'tags'}
  end
  
  def down
  end
  
end
