require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LayersController do

  #Delete this example and add some real ones
  it "should use LayersController" do 
    controller.should be_an_instance_of(LayersController)
  end

  describe "GET new" do
    
    it "should show form to let a user create a new layer" do
      @layer = mock_model Layer
      Layer.should_receive(:new).and_return(@layer)
      get :new
      response.should be_success
      response.should render_template('layers/new')
    end

  end


 

  describe "POST create valid" do

    before(:each) do
      Layer.stub!(:new).and_return(@layer = mock_model(Layer, :save=>true))
    end

    def do_create
      post :create, :layer=>{:name=>"value"}
    end

    it "should create a new layer" do
      Layer.should_receive(:new).with("name"=>"value").and_return(@layer)
      do_create
    end

    it "should save the new layer" do
      @layer.should_receive(:save).and_return(true)
      do_create
    end

    it "should redirect to the layer index" do
      do_create
      response.should redirect_to(layers_url)
    end

    it "should fail to create a new layer if given invalid stuff"

    it "should show the new layer form if given invalid stuffs"
  end

    describe "POST create invalid" do

    before(:each) do
      Layer.stub!(:new).and_return(@layer = mock_model(Layer, :save=>false))
   
    end

    def do_create
      post :create, :layer=>{:name=>"value"}
    end

    it "should create a new layer" do
      Layer.should_receive(:new).with("name"=>"value").and_return(@layer)
      do_create
    end

    it "should save the new layer" do
      @layer.should_receive(:save).and_return(false)
      do_create
    end

   it "should re-render the new form" do
    do_create
    response.should redirect_to(new_layer_path)
  end


  end

end
