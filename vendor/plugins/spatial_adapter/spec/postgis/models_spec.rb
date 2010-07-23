require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/postgis_raw'
require 'models/common'

describe "Spatially-enabled Models" do
  before :each do
    postgis_connection
    @connection = ActiveRecord::Base.connection
  end
  
  describe "inserting records" do
    it 'should save Point objects' do
      model = PointModel.new(:extra => 'test', :geom => GeometryFactory.point)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.point.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save LineString objects' do
      model = LineStringModel.new(:extra => 'test', :geom => GeometryFactory.line_string)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.line_string.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save Polygon objects' do
      model = PolygonModel.new(:extra => 'test', :geom => GeometryFactory.polygon)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.polygon.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save MultiPoint objects' do
      model = MultiPointModel.new(:extra => 'test', :geom => GeometryFactory.multi_point)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.multi_point.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save MultiLineString objects' do
      model = MultiLineStringModel.new(:extra => 'test', :geom => GeometryFactory.multi_line_string)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.multi_line_string.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save MultiPolygon objects' do
      model = MultiPolygonModel.new(:extra => 'test', :geom => GeometryFactory.multi_polygon)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.multi_polygon.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save GeometryCollection objects' do
      model = GeometryCollectionModel.new(:extra => 'test', :geom => GeometryFactory.geometry_collection)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.geometry_collection.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save Geometry objects' do
      model = GeometryModel.new(:extra => 'test', :geom => GeometryFactory.point)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.point.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save 3D Point (with Z coord) objects' do
      model = PointzModel.new(:extra => 'test', :geom => GeometryFactory.pointz)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.pointz.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save 3D Point (with M coord) objects' do
      model = PointmModel.new(:extra => 'test', :geom => GeometryFactory.pointm)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.pointm.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save 4D Point objects' do
      model = Point4Model.new(:extra => 'test', :geom => GeometryFactory.point4)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.point4.as_hex_ewkb))
      model.save.should == true
    end

    it 'should save Point geography objects' do
      model = GeographyPointModel.new(:extra => 'test', :geom => GeometryFactory.point)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.point.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save LineString geography objects' do
      model = GeographyLineStringModel.new(:extra => 'test', :geom => GeometryFactory.line_string)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.line_string.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save Polygon geography objects' do
      model = GeographyPolygonModel.new(:extra => 'test', :geom => GeometryFactory.polygon)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.polygon.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save MultiPoint geography objects' do
      model = GeographyMultiPointModel.new(:extra => 'test', :geom => GeometryFactory.multi_point)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.multi_point.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save MultiLineString geography objects' do
      model = GeographyMultiLineStringModel.new(:extra => 'test', :geom => GeometryFactory.multi_line_string)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.multi_line_string.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save MultiPolygon geography objects' do
      model = GeographyMultiPolygonModel.new(:extra => 'test', :geom => GeometryFactory.multi_polygon)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.multi_polygon.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save GeometryCollection geography objects' do
      model = GeographyGeometryCollectionModel.new(:extra => 'test', :geom => GeometryFactory.geometry_collection)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.geometry_collection.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save Geography objects' do
      model = GeographyModel.new(:extra => 'test', :geom => GeometryFactory.point)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.point.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save 3D Point (with Z coord) geography objects' do
      model = GeographyPointzModel.new(:extra => 'test', :geom => GeometryFactory.pointz)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.pointz.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save 3D Point (with M coord) geography objects' do
      model = GeographyPointmModel.new(:extra => 'test', :geom => GeometryFactory.pointm)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.pointm.as_hex_ewkb))
      model.save.should == true
    end
  
    it 'should save 4D Point geography objects' do
      model = GeographyPoint4Model.new(:extra => 'test', :geom => GeometryFactory.point4)
      @connection.should_receive(:select_value).with(Regexp.new(GeometryFactory.point4.as_hex_ewkb))
      model.save.should == true
    end
  end

  describe "finding records" do
    it 'should retrieve Point objects' do
      model = PointModel.create(:extra => 'test', :geom => GeometryFactory.point)
      PointModel.find(model.id).geom.should == GeometryFactory.point
    end
  
    it 'should retrieve LineString objects' do
      model = LineStringModel.create(:extra => 'test', :geom => GeometryFactory.line_string)
      LineStringModel.find(model.id).geom.should == GeometryFactory.line_string
    end
  
    it 'should retrieve Polygon objects' do
      model = PolygonModel.create(:extra => 'test', :geom => GeometryFactory.polygon)
      PolygonModel.find(model.id).geom.should == GeometryFactory.polygon
    end
  
    it 'should retrieve MultiPoint objects' do
      model = MultiPointModel.create(:extra => 'test', :geom => GeometryFactory.multi_point)
      MultiPointModel.find(model.id).geom.should == GeometryFactory.multi_point
    end
  
    it 'should retrieve MultiLineString objects' do
      model = MultiLineStringModel.create(:extra => 'test', :geom => GeometryFactory.multi_line_string)
      MultiLineStringModel.find(model.id).geom.should == GeometryFactory.multi_line_string
    end
  
    it 'should retrieve MultiPolygon objects' do
      model = MultiPolygonModel.create(:extra => 'test', :geom => GeometryFactory.multi_polygon)
      MultiPolygonModel.find(model.id).geom.should == GeometryFactory.multi_polygon
    end
  
    it 'should retrieve GeometryCollection objects' do
      model = GeometryCollectionModel.create(:extra => 'test', :geom => GeometryFactory.geometry_collection)
      GeometryCollectionModel.find(model.id).geom.should == GeometryFactory.geometry_collection
    end
  
    it 'should retrieve Geometry objects' do
      model = GeometryModel.create(:extra => 'test', :geom => GeometryFactory.point)
      GeometryModel.find(model.id).geom.should == GeometryFactory.point
    end
  
    it 'should retrieve 3D Point (with Z coord) objects' do
      model = PointzModel.create(:extra => 'test', :geom => GeometryFactory.pointz)
      PointzModel.find(model.id).geom.should == GeometryFactory.pointz
    end
  
    it 'should retrieve 3D Point (with M coord) objects' do
      model = GeographyPointmModel.create(:extra => 'test', :geom => GeometryFactory.pointm)
      GeographyPointmModel.find(model.id).geom.should == GeometryFactory.pointm
    end
  
    it 'should retrieve 4D Point objects' do
      model = GeographyPoint4Model.create(:extra => 'test', :geom => GeometryFactory.point4)
      GeographyPoint4Model.find(model.id).geom.should == GeometryFactory.point4
    end

    it 'should retrieve Point geography objects' do
      model = GeographyPointModel.create(:extra => 'test', :geom => GeometryFactory.point)
      GeographyPointModel.find(model.id).geom.should == GeometryFactory.point
    end
  
    it 'should retrieve LineString geography objects' do
      model = GeographyLineStringModel.create(:extra => 'test', :geom => GeometryFactory.line_string)
      GeographyLineStringModel.find(model.id).geom.should == GeometryFactory.line_string
    end
  
    it 'should retrieve Polygon geography objects' do
      model = GeographyPolygonModel.create(:extra => 'test', :geom => GeometryFactory.polygon)
      GeographyPolygonModel.find(model.id).geom.should == GeometryFactory.polygon
    end
  
    it 'should retrieve MultiPoint geography objects' do
      model = GeographyMultiPointModel.create(:extra => 'test', :geom => GeometryFactory.multi_point)
      GeographyMultiPointModel.find(model.id).geom.should == GeometryFactory.multi_point
    end
  
    it 'should retrieve MultiLineString geography objects' do
      model = GeographyMultiLineStringModel.create(:extra => 'test', :geom => GeometryFactory.multi_line_string)
      GeographyMultiLineStringModel.find(model.id).geom.should == GeometryFactory.multi_line_string
    end
  
    it 'should retrieve MultiPolygon geography objects' do
      model = GeographyMultiPolygonModel.create(:extra => 'test', :geom => GeometryFactory.multi_polygon)
      GeographyMultiPolygonModel.find(model.id).geom.should == GeometryFactory.multi_polygon
    end
  
    it 'should retrieve GeometryCollection geography objects' do
      model = GeographyGeometryCollectionModel.create(:extra => 'test', :geom => GeometryFactory.geometry_collection)
      GeographyGeometryCollectionModel.find(model.id).geom.should == GeometryFactory.geometry_collection
    end
  
    it 'should retrieve Geometry geography objects' do
      model = GeographyModel.create(:extra => 'test', :geom => GeometryFactory.point)
      GeographyModel.find(model.id).geom.should == GeometryFactory.point
    end
  
    it 'should retrieve 3D Point (with Z coord) geography objects' do
      model = GeographyPointzModel.create(:extra => 'test', :geom => GeometryFactory.pointz)
      GeographyPointzModel.find(model.id).geom.should == GeometryFactory.pointz
    end
  
    it 'should retrieve 3D Point (with M coord) geography objects' do
      model = GeographyPointmModel.create(:extra => 'test', :geom => GeometryFactory.pointm)
      GeographyPointmModel.find(model.id).geom.should == GeometryFactory.pointm
    end
  
    it 'should retrieve 4D Point geography objects' do
      model = GeographyPoint4Model.create(:extra => 'test', :geom => GeometryFactory.point4)
      GeographyPoint4Model.find(model.id).geom.should == GeometryFactory.point4
    end
  end
end

