require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class MigratedGeometryModel < ActiveRecord::Base
end

describe "Spatially-enabled Migrations" do
  before :each do
    mysql_connection
    @connection = ActiveRecord::Base.connection
  end
  
  describe "creating tables" do
    after :each do
      @connection.drop_table "migrated_geometry_models"
    end
    
    SpatialAdapter.geometry_data_types.keys.each do |type|
      it "should create #{type.to_s} columns" do
        ActiveRecord::Schema.define do
          create_table :migrated_geometry_models, :force => true do |t|
            t.integer :extra
            t.send(type, :geom)
          end
        end

        geom_column = @connection.columns(:migrated_geometry_models).select{|c| c.name == 'geom'}.first
        geom_column.should be_a(SpatialAdapter::SpatialColumn)
        geom_column.geometry_type.should == type
        geom_column.type.should == :geometry
      end
    end
  end

  describe "adding columns" do
    before :each do
      ActiveRecord::Schema.define do
        create_table :migrated_geometry_models, :force => true do |t|
          t.integer :extra
        end
      end
    end
    
    after :each do
      @connection.drop_table "migrated_geometry_models"
    end

    SpatialAdapter.geometry_data_types.keys.each do |type|
      it "should add #{type.to_s} columns" do
        ActiveRecord::Schema.define do
          add_column :migrated_geometry_models, :geom, type
        end

        geom_column = @connection.columns(:migrated_geometry_models).select{|c| c.name == 'geom'}.first
        geom_column.should be_a(SpatialAdapter::SpatialColumn)
        geom_column.geometry_type.should == type
        geom_column.type.should == :geometry
        geom_column.with_z.should == false
        geom_column.with_m.should == false
        geom_column.srid.should == -1
      end
    end
  end
end