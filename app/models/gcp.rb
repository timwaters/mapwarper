class Gcp < ActiveRecord::Base
  belongs_to :map
  audited :allow_mass_assignment => true
  
  validates_numericality_of :x, :y, :lat, :lon
  validates_presence_of :x, :y, :lat, :lon, :map_id
  
  scope :soft, -> { where(:soft => true)}
  scope :hard, -> { where('soft IS NULL OR soft = ?', false) }
  
  attr_accessor :error
  
  after_save :update_map_timestamp
  after_destroy :update_map_timestamp
  
  def gdal_string
	
    gdal_string = " -gcp " + x.to_s + ", " + y.to_s + ", " + lon.to_s + ", " + lat.to_s

  end

  
  private
  def update_map_timestamp
    self.map.update_gcp_touched_at
  end
  
end
