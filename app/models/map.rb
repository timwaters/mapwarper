class Map < ActiveRecord::Base
  
  has_many :gcps,  :dependent => :destroy
  has_many :layers_maps,  :dependent => :destroy
  has_many :layers, :through => :layers_maps # ,:after_add, :after_remove
  
  acts_as_taggable
  acts_as_enum :map_type, [:index, :is_map, :not_map ]
  
  def depicts_year
    self.layers.with_year.collect(&:depicts_year).compact.first
  end
  
  #############################################
  #CLASS METHODS
  #############################################

  def self.map_type_hash
    values = Map::MAP_TYPE
    keys = ["Index/Overview", "Is a map", "Not a map"]
    Hash[*keys.zip(values).flatten]
  end
  
   def warped_or_published?
    return [:warped, :published].include?(status)
  end
  
end