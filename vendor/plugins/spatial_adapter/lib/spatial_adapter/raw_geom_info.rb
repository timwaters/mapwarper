module SpatialAdapter
  class RawGeomInfo < Struct.new(:type,:srid,:dimension,:with_z,:with_m) #:nodoc:
    def convert!
      self.type = "geometry" if self.type.nil? #if geometry the geometrytype constraint is not present : need to set the type here then
    
      if dimension == 4
        self.with_m = true
        self.with_z = true
      elsif dimension == 3
        if with_m
          self.with_z = false
          self.with_m = true 
        else
          self.with_z = true
          self.with_m = false
        end
      else
        self.with_z = false
        self.with_m = false
      end
    end
  end
end
