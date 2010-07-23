module SpatialAdapter
  module SpatialColumn
    attr_reader  :geometry_type, :srid, :with_z, :with_m

    def initialize(name, default, sql_type = nil, null = true, srid=-1, with_z=false, with_m=false)
      super(name, default, sql_type, null)
      @geometry_type = geometry_simplified_type(@sql_type)
      @srid = srid
      @with_z = with_z
      @with_m = with_m
    end
  
    def geographic?
      false
    end

    # Redefines type_cast to add support for geometries
    # alias_method :type_cast_without_spatial, :type_cast
    def type_cast(value)
      return nil if value.nil?
      case type
      when :geometry then self.class.string_to_geometry(value)
      else super
      end
    end

    #Redefines type_cast_code to add support for geometries. 
    #
    #WARNING : Since ActiveRecord keeps only the string values directly returned from the database, it translates from these to the correct types everytime an attribute is read (using the code returned by this method), which is probably ok for simple types, but might be less than efficient for geometries. Also you cannot modify the geometry object returned directly or your change will not be saved. 
    # alias_method :type_cast_code_without_spatial, :type_cast_code
    def type_cast_code(var_name)
      case type
      when :geometry then "#{self.class.name}.string_to_geometry(#{var_name})"
      else super
      end
    end


    #Redefines klass to add support for geometries
    # alias_method :klass_without_spatial, :klass
    def klass
      case type
      when :geometry then GeoRuby::SimpleFeatures::Geometry
      else super
      end
    end

    private

    #Redefines the simplified_type method to spatial columns
    def simplified_type(field_type)
      case field_type
      when /geography|geometry|point|linestring|polygon|multipoint|multilinestring|multipolygon|geometrycollection/i then :geometry
      else super
      end
    end

    # less simlpified geometric type to be use in migrations
    def geometry_simplified_type(sql_type)
      case sql_type
      when /^point$/i then :point
      when /^linestring$/i then :line_string
      when /^polygon$/i then :polygon
      when /^geometry$/i then :geometry
      when /multipoint/i then :multi_point
      when /multilinestring/i then :multi_line_string
      when /multipolygon/i then :multi_polygon
      when /geometrycollection/i then :geometry_collection
      end
    end
  end
end
