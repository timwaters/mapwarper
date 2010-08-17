class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  validates_uniqueness_of :user_id, :scope =>  :group_id, :message => "User is already a member of this group"
end
