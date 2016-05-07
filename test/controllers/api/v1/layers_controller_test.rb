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
  
  test "get layer" do
    get 'show', :id => @layer.id, :format => :json
    assert_response :ok
    assert_response :success
    assert_not_nil assigns(:layer)
    body = JSON.parse(response.body)
    assert_equal @layer.name, body["data"]["attributes"]["name"]
  end
  
  #index
  test "index" do
    get 'index', :format => :json
    assert_response :ok
    assert_not_nil assigns(:layers)
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].length
    assert_equal @layer.name, body["data"][0]["attributes"]["name"]
  end
  
  
  #sorting / ordering
  
  #geosearch
  
  
  test "maps layers" do
    map = @layer.maps.first
    get :index, :map_id => map.id, :format => :json
    assert_response :success
    assert_not_nil assigns(:layers)
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].length
  end
  
  
  #create
  
  #update
  
  #delete
  
  #visibility
    
  #remove map

  
end