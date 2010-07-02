class Gcp < ActiveRecord::Base
belongs_to :map


validates_numericality_of :x, :y, :lat, :lon
validates_presence_of :x, :y, :lat, :lon, :map_id

attr_accessor :error

def gdal_string
	
gdal_string = " -gcp " + x.to_s + ", " + y.to_s + ", " + lon.to_s + ", " + lat.to_s

end

end


