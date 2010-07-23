require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Spatially-enabled Schema Dumps" do
  before :all do
    postgis_connection
    @connection = ActiveRecord::Base.connection

    # Create a new table
    ActiveRecord::Schema.define do
      create_table :migrated_geometry_models, :force => true do |t|
        t.integer :extra
        t.point   :geom, :with_m => true, :with_z => true, :srid => 4326
      end
      add_index :migrated_geometry_models, :geom, :spatial => true, :name => 'test_spatial_index'

      create_table :migrated_geography_models, :force => true do |t|
        t.integer :extra
        t.point   :geom, :with_m => true, :with_z => true, :geographic => true
      end
    end

    File.open('schema.rb', "w") do |file|
      ActiveRecord::SchemaDumper.dump(@connection, file)
    end
    
    # Drop the original tables
    @connection.drop_table "migrated_geometry_models"
    @connection.drop_table "migrated_geography_models"
    
    # Load the dumped schema
    load('schema.rb')
  end
  
  after :all do
    # delete the schema file
    File.delete('schema.rb')

    # Drop the new tables
    @connection.drop_table "migrated_geometry_models"
    @connection.drop_table "migrated_geography_models"
  end
  
  it "should preserve spatial attributes of geometry tables" do
    columns = @connection.columns("migrated_geometry_models")
    
    columns.should have(3).items
    geom_column = columns.select{|c| c.name == 'geom'}.first
    geom_column.should be_a(SpatialAdapter::SpatialColumn)
    geom_column.geometry_type.should == :point
    geom_column.type.should == :geometry
    geom_column.with_z.should == true
    geom_column.with_m.should == true
    geom_column.srid.should == 4326
  end
  
  it "should preserve spatial attributes of geography tables" do
    columns = @connection.columns("migrated_geography_models")
    
    columns.should have(3).items
    geom_column = columns.select{|c| c.name == 'geom'}.first
    geom_column.should be_a(SpatialAdapter::SpatialColumn)
    geom_column.geometry_type.should == :point
    geom_column.type.should == :geometry
    geom_column.with_z.should == true
    geom_column.with_m.should == true
    geom_column.should be_geographic
  end
  
  it "should preserve spatial indexes" do
    indexes = @connection.indexes("migrated_geometry_models")
    
    indexes.should have(1).item
    
    indexes.first.name.should == 'test_spatial_index'
    indexes.first.columns.should == ["geom"]
    indexes.first.spatial.should == true
  end
end