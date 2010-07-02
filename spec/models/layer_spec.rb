require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Layer do
  before(:each) do
    @valid_attributes = {
      :name => "a layer"
    }
    @tileindex = "spec/fixtures/maps/deleteme.shp"
  end

  describe "just after creation" do
    
    it "should create a new instance given valid attributes" do
      Layer.create!(@valid_attributes)
    end

    it "should have a name" do
      @layer = Layer.new :name => ""
      @layer.should_not be_valid
      @layer.should have(1).errors_on(:name)
      @layer.name = "something"
      @layer.should be_valid
      @layer.should have(0).errors_on(:name)
    end

  end

  describe "after a map has been added " do

    before(:each) do
      @layer = Layer.new(@valid_attributes)
      @map = mock_model(Map, :to_param =>"1", :warped_filename =>"spec/fixtures/maps/41.tif",:save => true)
      Map.stub!(:new).and_return(@map)
      @layer.maps << @map
    end


    it "should have a tileindex filename" do
      @layer.tileindex_filename.should_not be_nil
    end

    it "should have an accurate count of maps" do
      @layer.should have(1).maps
      @layer.should_not have(2).maps
      @map2 = mock_model(Map, :to_param =>"2",:warped_filename =>"spec/fixtures/maps/41.tif", :save => true)
      @layer.maps << @map2
      @layer.should have(2).maps
    end
    
    it "should make or recreate a tileindex" do
      @map2 = mock_model(Map, :to_param =>"2",:warped_filename =>"spec/fixtures/maps/47.tif", :save => true)
      @layer.maps << @map2
      @layer.create_tileindex(@tileindex).should be(true)
    end

     

  end

  describe "with no maps" do
    before(:each) do
      @layer = Layer.new(@valid_attributes)
      @layer.maps = []
    end

    it "should not have a bounding box "do
      @layer.set_bounds(@tileindex)
      @layer.bounds.should be_nil
    end

    it "should have zero  maps" do
      @layer.should have(0).maps
    end

    it "should not make or recreate a tileindex" do
      @layer.create_tileindex(@tileindex).should be(false)
    end
   
  end

  describe "processing the layer" do

    before(:each) do
      @layer = Layer.new(@valid_attributes)
      @layer.id = 1
      @map = mock_model(Map, :to_param =>"1", :title=>"ss", :warped_filename =>"spec/fixtures/maps/41.tif",:save => true)
      Map.stub!(:new).and_return(@map)
      Map.stub!(:setup_image).and_return(true)
      @layer.maps << @map
    end

#    it "should have a bounding box "do
#      @layer.set_bounds(@tileindex)
#      @layer.bounds.should_not be_nil
#      @layer.bounds.split(',').should have(4).items
#    end
    
    it "should make or recreate a tileindex" do
      @layer.create_tileindex(@tileindex).should be(true)
    end

    it "should make a mapfile for tileindex" do
      @layer.save_mapfile("spec/fixtures/maps/del.map",@tileindex).should be(true)
    end
   
  end


end
