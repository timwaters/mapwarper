module Rubaidh
  module DefaultValues
    def self.included(base)
      base.extend(ActsMethods)
    end

    module ActsMethods
      def default_values(values = {})
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :default_value_options
          include InstanceMethods
          alias_method_chain :initialize, :default_values
        end
        self.default_value_options = values
      end
      alias_method :default_value, :default_values
    end

    module InstanceMethods
      def initialize_with_default_values(*args)
        returning initialize_without_default_values(*args) do
          default_value_options.each do |k, v|
            v = v.call if v.respond_to?(:call)
            write_attribute(k, v) if read_attribute(k).nil?
          end
        end
      end
    end
  end
end