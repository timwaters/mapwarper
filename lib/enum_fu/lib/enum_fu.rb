module EnumFu
  def self.included(including_class)
    including_class.class_eval do

      # make a enum colume in active record model 
      # db schema
      #	  create_table 'users' do |t|
      #	    t.column 'role', :integer, :limit => 2
      #	  end
      #
      # model
      #	  class User < ActiveRecord::Base
      #	    acts_as_enum :role, [:customer, :admin]
      #	  end
      def self.acts_as_enum(name, values)
        # keep original name  in n to use later, 
        # I don't know why, but name's value is changed later
        n = name.to_s.dup

        # define an array contant with the given values
        # example: Car::STATUS =>  [:normal, :broken, :running]
        const_name = name.to_s.upcase
        self.const_set const_name, values

        # define a singleton method which get the enum value
        # example: Car.status(:broken)   =>  1
        p1 =  Proc.new { |v| self.const_get(const_name).index(v) }
        self.class.send(:define_method, name, p1)

        # define an instance get/set methods  which get/set  the enum value
        # example: 
        # c = Car.new :status => :normal  
        # c.status => :normal
        # c.status = :broken
        #
        p2 =  Proc.new {
          # Before patch (Do not allow nil value)
          #  self.class.const_get(const_name)[read_attribute(name.to_s)||0]
          
	  # After patch by Josh Goebel (Now, it will return nil when db value is nil)
          attr_name = read_attribute(name.to_s)
          attr_name.nil? ? nil : self.class.const_get(const_name)[attr_name]
        }
        define_method name.to_sym, p2

        p3 =  Proc.new { |sym|
          # Before patch (Do not allow nil value)
          #write_attribute name.to_s, self.class.const_get(const_name).index(sym.to_sym)
          
          # After patch by Georg Ledermann (Now it's possible to set as null Ex: c.status = nil )
          write_attribute name.to_s, (sym.blank? ? nil : self.class.const_get(const_name).index(sym.to_sym))
        }
        define_method name.to_s+'=', p3
      end
    end
  end
end

