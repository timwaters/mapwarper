class Layer < ActiveRecord::Base
  has_many :layers_maps, :dependent => :destroy
  has_many :maps,:through => :layers_maps
  
  scope :with_year, -> { where(:depicts_year =>  'is not null').order(:maps_count) }
  #named_scope :with_year, :order => :maps_count, :conditions => "depicts_year is not null"

end
