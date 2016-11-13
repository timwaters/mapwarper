class LayersMap < ActiveRecord::Base
  belongs_to :layer
  belongs_to :map

  validates_uniqueness_of :layer_id, :scope => :map_id, :message => :already_has_map
end
