include SpatialAdapter

ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  SpatialAdapter.geometry_data_types.keys.each do |column_type|
    class_eval <<-EOV
      def #{column_type}(*args)
        options = args.extract_options!
        column_names = args
      
        column_names.each { |name| column(name, '#{column_type}', options) }
      end
    EOV
  end
end
