# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.dirname(__FILE__) + '/../spec_helper'
require 'map'


describe Map do

    

  describe "after being created" do
    before(:each) do
      @valid_attributes = {
        :title => "a title"
      }
    end
    before(:each) do
      @map = Map.new
    end
    it "should be downloadable" do
      @map.attributes = @valid_attributes.with(:downloadable => false)
      @map.should_not be_downloadable
      @map.attributes = @valid_attributes.with(:downloadable => true)
      @map.should be_downloadable
    end
  end

  describe "bounding box" do
     before(:each) do
      @valid_attributes = {
        :title => "a title",
        :filename => "1978079297_19a2f091fb_b.jpg.tif"
      }

    end

    before(:each) do
      @map = Map.new(@valid_attributes)
      @map.id = 50
   
      @gcp1 = Gcp.new( :map_id =>50, :x =>286.463 , :y=>129.359 , :lat =>41.2730063382, :lon =>-84.1192382812 )
      @gcp2 = Gcp.new( :map_id =>50, :x =>814.497 , :y=>37.4342 , :lat=>42.126084433 ,:lon =>-77.5274414064)
      @gcp3 = Gcp.new( :map_id =>50, :x =>649.8875, :y=>426.511, :lat=>38.4055533628 ,:lon =>-78.8897460939)
      @gcps = [@gcp1, @gcp2, @gcp3]
      @map.gcps = @gcps
    end

   
    it "should give an approximate bbox if not warped and theres more than three control points" do
      @map.status = :available
      @map.bounds.should eql("-84.1192382812,38.4055533628,-77.5274414064,42.126084433")
    end


    it "should give an accurate bounding box if warped" do
      @map.status = :warped
      @map.save_bbox
      @map.bounds.should eql("-88.0397750,35.9367055,-73.6057889,42.5280968")
    end

  end

end

