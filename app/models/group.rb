class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :groups_maps, :dependent => :destroy
  has_many :maps, :through => :groups_maps
  belongs_to :creator, :class_name => "User"
end
