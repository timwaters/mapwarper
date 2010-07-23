ActiveRecord::SchemaDumper.ignore_tables << "spatial_ref_sys" << "geometry_columns"

ActiveRecord::SchemaDumper.class_eval do
  # These are the valid options for a column specification (spatial options added)
  VALID_COLUMN_SPEC_KEYS = [:name, :limit, :precision, :scale, :default, :null, :srid, :with_z, :with_m, :geographic]
  
  def table(table, stream)
    columns = @connection.columns(table)
    begin
      tbl = StringIO.new

      # first dump primary key column
      if @connection.respond_to?(:pk_and_sequence_for)
        pk, pk_seq = @connection.pk_and_sequence_for(table)
      elsif @connection.respond_to?(:primary_key)
        pk = @connection.primary_key(table)
      end
      
      tbl.print "  create_table #{table.inspect}"
      if columns.detect { |c| c.name == pk }
        if pk != 'id'
          tbl.print %Q(, :primary_key => "#{pk}")
        end
      else
        tbl.print ", :id => false"
      end
      
      # Added by Spatial Adapter to ensure correct MySQL table engine
      if @connection.respond_to?(:options_for)
        res = @connection.options_for(table)
        tbl.print ", :options=>'#{res}'" if res
      end
      
      tbl.print ", :force => true"
      tbl.puts " do |t|"

      # then dump all non-primary key columns
      column_specs = columns.map do |column|
        raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
        next if column.name == pk
        spec = column_spec(column)
        (spec.keys - [:name, :type]).each{ |k| spec[k].insert(0, "#{k.inspect} => ")}
        spec
      end.compact

      # find all migration keys used in this table
      keys = VALID_COLUMN_SPEC_KEYS & column_specs.map(&:keys).flatten

      # figure out the lengths for each column based on above keys
      lengths = keys.map{ |key| column_specs.map{ |spec| spec[key] ? spec[key].length + 2 : 0 }.max }

      # the string we're going to sprintf our values against, with standardized column widths
      format_string = lengths.map{ |len| "%-#{len}s" }

      # find the max length for the 'type' column, which is special
      type_length = column_specs.map{ |column| column[:type].length }.max

      # add column type definition to our format string
      format_string.unshift "    t.%-#{type_length}s "

      format_string *= ''

      column_specs.each do |colspec|
        values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
        values.unshift colspec[:type]
        tbl.print((format_string % values).gsub(/,\s*$/, ''))
        tbl.puts
      end

      tbl.puts "  end"
      tbl.puts
      
      indexes(table, tbl)

      tbl.rewind
      stream.print tbl.read
    rescue => e
      stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
      stream.puts "#   #{e.message}"
      stream.puts
    end
    
    stream
  end
  

  def indexes(table, stream)
    if (indexes = @connection.indexes(table)).any?
      add_index_statements = indexes.map do |index|
        statment_parts = [ ('add_index ' + index.table.inspect) ]
        statment_parts << index.columns.inspect
        statment_parts << (':name => ' + index.name.inspect)
        statment_parts << ':unique => true' if index.unique
        # Add spatial option (this is the only change from the original method)
        statment_parts << ':spatial => true' if index.spatial

        '  ' + statment_parts.join(', ')
      end

      stream.puts add_index_statements.sort.join("\n")
      stream.puts
    end
  end
  
  private
  
  # Build specification for a table column
  def column_spec(column)
    spec = {}
    spec[:name]      = column.name.inspect
    
    # AR has an optimisation which handles zero-scale decimals as integers.  This
    # code ensures that the dumper still dumps the column as a decimal.
    spec[:type]      = if column.type == :integer && [/^numeric/, /^decimal/].any? { |e| e.match(column.sql_type) }
                         'decimal'
                       else
                         column.type.to_s
                       end
    spec[:limit]     = column.limit.inspect if column.limit != @types[column.type][:limit] && spec[:type] != 'decimal'
    spec[:precision] = column.precision.inspect if !column.precision.nil?
    spec[:scale]     = column.scale.inspect if !column.scale.nil?
    spec[:null]      = 'false' if !column.null
    spec[:default]   = default_string(column.default) if column.has_default?
    
    # Additions for spatial columns
    if column.is_a?(SpatialColumn)
      # Override with specific geometry type
      spec[:type]    = column.geometry_type.to_s
      spec[:srid]    = column.srid.inspect if column.srid != -1
      spec[:with_z]  = 'true' if column.with_z
      spec[:with_m]  = 'true' if column.with_m
      spec[:geographic] = 'true' if column.geographic?
    end
    spec
  end
end
