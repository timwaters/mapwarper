class GroupsMap < ActiveRecord::Base
  belongs_to :group
  belongs_to :map
  validates_uniqueness_of :map_id, :scope => :group_id, :message => "Map has already been saved to this group"
end
