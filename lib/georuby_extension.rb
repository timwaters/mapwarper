module GeoRuby
  module SimpleFeatures
    class Polygon
      def to_json(options = nil)
        coords = self.first.points.collect {|point| [point.x, point.y] }
        {:type => "Polygon", 
          :coordinates => coords}.to_json
      end
    end
    class Point
      def to_json(options = nil)
        {:type => "Point", 
          :coordinates => [self.x, self.y]}.to_json
      end
    end  
    class LineString
      def to_json(options = nil)
        coords = self.points.collect {|point| [point.x, point.y] }
        {:type => "LineString", 
          :coordinates => coords}.to_json
      end
    end 
    class GeometryCollection
      def to_json(options = nil)
        {:type => "GeometryCollection", 
          :geometries => self.geometries}.to_json        
      end
    end 
  end
end


