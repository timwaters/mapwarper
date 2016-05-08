require 'test_helper'

class LayersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::LayersController
  
  setup do
    @layer = FactoryGirl.create(:layer_with_maps)
  end
  
  teardown do
    @layer.send(:delete_tileindex)
  end
  
  class CollectionTest < LayersControllerTest 
    setup do
      @warped_layer = FactoryGirl.create(:layer_with_warped_maps)
      @index_layers = FactoryGirl.create_list(:index_layer, 5)
    end
    
    #index
    test "index" do
      get 'index', :format => :json
      assert_response :ok
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal Layer.count, body["data"].length
    end
  
    test "sorting" do
      get 'index', :sort_key => "name", :sort_order =>"asc"
      assert_response :ok
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal Layer.count, body["data"].length
      assert_equal @index_layers.first.name, body["data"][0]["attributes"]["name"]
    end
  
    #NOTE: percent sorting only gets those with maps in them
    #
    test "percent sorting" do
      get 'index', :sort_key => "percent", :sort_order =>"desc"
      assert_response :ok
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal 2, body["data"].length
      assert_equal @layer.name, body["data"][0]["attributes"]["name"]
    end
  
  
    #geosearch
    
    test "geosearch" do
      #intersects: POLYGON((26.779899697812 58.421402710855, 26.779213052304 58.328018921793, 26.849250894101 58.329392212808, 26.849937539609 58.422089356363, 26.779899697812 58.421402710855))
      #bbox = 26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855
      
      #within: POLYGON((26.633644204648 58.428269165933, 26.63295755914 58.302613038003, 26.859550576718 58.301239746988, 26.85886393121 58.428955811441, 26.633644204648 58.428269165933))
      #bbox = 26.633644204648, 58.302613038003, 26.859550576718, 58.428269165933
      #this bbox intersects our map intersects (but does not encompass it)
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :operation => "intersect", :format => :json
      assert_response :success
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)

      assert_equal @layer.name, body["data"][0]["attributes"]["name"]
      
      #within, so expect 0
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :operation => "within", :format => :json
      assert_response :success
      assert_empty assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal [], body["data"]
      
      # now with the bbox that encompasses it all
      
      get :index, :bbox => "26.633644204648, 58.302613038003, 26.859550576718, 58.428269165933", :operation => "intersect", :format => :json
      assert_response :success
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal @layer.name, body["data"][0]["attributes"]["name"]
      
      #within, so expect 0
      get :index, :bbox => "26.633644204648, 58.302613038003, 26.859550576718, 58.428269165933", :operation => "within", :format => :json
      assert_response :success
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal @layer.name, body["data"][0]["attributes"]["name"]
      
    end
    
    test "geosearch with query" do
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :query =>"name",:operation => "intersect", :format => :json
      assert_response :success
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal @layer.name, body["data"][0]["attributes"]["name"]
      
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :query =>"layer",:operation => "intersect", :format => :json
      assert_response :success
      assert_empty assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal [], body["data"]
      
    end
  
    test "maps layers" do
      map = @layer.maps.first
      get :index, :map_id => map.id, :format => :json
      assert_response :success
      assert_not_nil assigns(:layers)
      body = JSON.parse(response.body)
      assert_equal 1, body["data"].length
    end
  
  end
  
  class MemberTest < LayersControllerTest
  
    test "get layer" do
      get 'show', :id => @layer.id, :format => :json
      assert_response :ok
      assert_response :success
      assert_not_nil assigns(:layer)
      body = JSON.parse(response.body)
      assert_equal @layer.name, body["data"]["attributes"]["name"]
    end
    #create
  
    #update
  
    #delete
  
    #visibility
    
    #remove map
  end
  
end