require File.dirname(__FILE__) + '/../spec_helper'

describe MapsController, "handling new POST /maps (create)" do
  before do
    @map = mock_model(Map, :to_param =>"1", :save => true)
    Map.stub!(:new).and_return(@map)
    @params = {"title" => "a title"}
  end

  def do_post
    post :create, :map => @params
  end

  it "should create a new map" do
    Map.should_receive(:new).with(@params).and_return(@map)
    do_post
  end

  it "should redirect to show the new map" do
    do_post
    response.should redirect_to(map_url("1"))
  end

end

describe MapsController, "handling new GET /maps (index)" do

  before do
    @map = mock_model(Map)
    Map.stub!(:find).and_return([@map])
  end

  def do_get
    get :index
  end


  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template("index")
  end

  it "should find some maps" do
    Map.should_receive(:find).and_return([@map])
    do_get
  end
  it "should assign found maps to the view" do
    do_get
    assigns[:maps].should == [@map]
  end

end

describe MapsController, "handling new GET maps/tag/tag_name " do
 
  before do
    @map = mock_model(Map)
    Map.stub!(:paged_find_tagged_with).and_return([@map])
  end

  def do_get
    get :tag, :id => "foo"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render tag template" do
    do_get
    response.should render_template("tag")
  end

  it "should find and paginate maps with tags" do

    Map.should_receive(:paged_find_tagged_with).with("foo",
    :order=>"updated_at desc", :page=>nil,  :per_page=>20).and_return([@map])
    do_get
  end
  
  it "should assign found paginated maps to the view" do
    Map.should_receive(:paged_find_tagged_with).with("foo", :order=>"updated_at desc", :page=>nil, :per_page=>20).and_return([@map])
    do_get
    assigns[:maps].should == [@map]
  end

end


describe MapsController, "handling new GET maps/tag/tag_name.rss " do
integrate_views
  before do
    @map = mock_model(Map, :title=>"a title", :description => "descr", :created_at => Time.now)
    Map.stub!(:paged_find_tagged_with).and_return([@map])
  end

  def do_get
    @request.accept = "application/rss"
    get :tag, :id => "foo", :format => "rss"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
   it "should render the found maps as rss" do
   do_get
   response.body.should have_tag("rss")
   response.body.should have_tag("title", :text => "Feed of Warper Maps tagged with foo")
  end


  it "should find and paginate maps with tags" do
    Map.should_receive(:paged_find_tagged_with).with("foo",
    :order=>"updated_at desc", :page=>nil,  :per_page=>20).and_return([@map])
    do_get
  end
  
  it "should assign found paginated maps to the template" do
    Map.should_receive(:paged_find_tagged_with).with("foo",
    :order=>"updated_at desc", :page=>nil, :per_page=>20).and_return([@map])
    do_get
    assigns[:maps].should == [@map]
  end



end

