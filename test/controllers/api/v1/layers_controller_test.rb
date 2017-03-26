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
    
    setup do 
      admin_sign_in
    end
  
    test "get layer" do
      get 'show', :id => @layer.id, :format => :json
      assert_response :ok
      assert_response :success
      assert_not_nil assigns(:layer)
      body = JSON.parse(response.body)
      assert_equal @layer.name, body["data"]["attributes"]["name"]
    end
    
    #create
    test "create" do
      assert_difference('Layer.count', 1) do
       post 'create', 'data' => {'type' => "layers", "attributes"=>{:name => "new layer", :description => "bar"}} 
      end
      assert_response :created
      
      body = JSON.parse(response.body)
      assert_equal "new layer", body["data"]["attributes"]["name"]
      id = body["data"]["id"]
      Layer.find(id).send(:delete_tileindex)#cleanup
    end
    
    test "create with maps" do
      warped_map = FactoryGirl.create(:warped_map)
      assert_difference('Layer.count', 1) do
        post 'create', 'data' => {'type' => "layers", "attributes"=>{:name => "new layer", :description => "bar"}, :map_ids => [warped_map.id]} 
      # puts response.body
      end
      assert_response :created
      
      body = JSON.parse(response.body)
      assert_equal "new layer", body["data"]["attributes"]["name"]
      id = body["data"]["id"]
      assert_equal 1, Layer.find(id).maps.count
      assert_equal warped_map.title, Layer.find(id).maps.first.title
      
      Layer.find(id).send(:delete_tileindex)  #cleanup
    end
    
    test "update" do
      patch 'update', :id => @layer.id, 'data' => {'type' => "layers", "attributes"=>{:name => "updated layer"}}
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "updated layer", body["data"]["attributes"]["name"]
    end
    
    test "update with maps" do
      warped_map = FactoryGirl.create(:warped_map)
      before_count = @layer.maps.count
    
      patch 'update', :id => @layer.id,  'data' => {'type' => "layers", "attributes"=>{:name => "updated layer"}, :map_ids => [warped_map.id]}
      after_count = @layer.reload.maps.count
      
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "updated layer", body["data"]["attributes"]["name"]
      assert_equal 1, after_count - before_count 
      assert_equal warped_map.title, @layer.maps.first.title
    end
    
    test "delete" do
      assert_difference('Layer.count', -1) do
        delete 'destroy',:id => @layer.id
      end
      assert_response :success
    end
  
    #visibility (patch)
    test "visible" do
      patch 'toggle_visibility', :id => @layer.id
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal false, body["data"]["attributes"]["is_visible"]
    end
    
    test "remove map" do
      map_id = @layer.maps.first.id
      patch "remove_map", :id => @layer.id, :map_id => map_id
      assert_equal 0, @layer.maps.count
    end
    
    test "merge" do
      dest_layer = FactoryGirl.create(:layer_with_warped_maps)
      assert_equal 1, dest_layer.maps.count
      Map.any_instance.stubs(:warped_filename).returns(File.join(dest_layer.maps.first.warped_dir, "100x70map_warped.tif"))
      patch 'merge', :id =>@layer.id, :dest_id => dest_layer.id
      
      assert_response :ok
      assert_equal 2, dest_layer.maps.count
      
      body = JSON.parse(response.body)
      assert_equal dest_layer.id, body["data"]["id"].to_i
    end

  end
  
end