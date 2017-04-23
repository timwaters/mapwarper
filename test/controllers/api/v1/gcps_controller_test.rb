require 'test_helper'

class GcpsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::GcpsController
  
  setup do
    @map =    FactoryGirl.create(:warped_map)
    @gcp =    FactoryGirl.create(:gcp_1, :map => @map)
    @gcp_2  = FactoryGirl.create(:gcp_2, :map => @map)
    @gcp_3  = FactoryGirl.create(:gcp_3, :map => @map)
      
    @user = FactoryGirl.create(:user)
    request.env["devise.mapping"] = Devise.mappings[:user] 
    sign_in @user 
  end
  
  test "show"do
    get 'show', :id  => @gcp.id
    assert_response :ok
    assert_not_nil assigns(:gcp)
    body = JSON.parse(response.body)
    assert_equal @gcp.id, body["data"]["id"].to_i
  end
  
  test "create with no map id" do
    assert_difference('Gcp.count', 0) do
      post 'create', 'data' => {'type' => "gcps", "attributes"=>{"x"=>1}}
    end
    assert_response :unprocessable_entity
    assert response.body.include?("map_id")
  end
  
  test "create" do
    assert_difference('Gcp.count', 1) do
      post 'create', 'data' => {'type' => "gcps","attributes"=>{:x=>1, :y =>2, :lat => 33.3, :lon => 44.4, :map_id => @map.id}}
    end
    assert_response :created
    
    body = JSON.parse(response.body)
    assert_equal 1, body["data"]["attributes"]["x"].to_i
    assert_equal @map.id, body["data"]["attributes"]["map_id"].to_i
  end
  
  test "update" do
    patch "update", :id => @gcp.id, 'data' => {'type' => "gcps", "attributes"=>{"x"=>99}}
    assert_response :ok
    
    body = JSON.parse(response.body)
    assert_equal 99, body["data"]["attributes"]["x"].to_i
  end
  
  test "delete" do
    assert_difference('Gcp.count', -1) do
      delete 'destroy', :id => @gcp.id
    end
    assert_response :ok
    
    body = JSON.parse(response.body)
    assert_equal @gcp.id, body["data"]["id"].to_i
  end
  
  test "index" do
    get 'index'
    assert_response :ok
    assert_not_nil assigns(:gcps)
    body = JSON.parse(response.body)
    assert_equal 3, body["data"].size
  end
  
  test "add_many" do
    sign_out @user
    editor_user_sign_in
    post 'add_many', :gcps => [{"mapid" => @map.id,"x" => 1.2,"y"=>2.2, "lat"=>11.1, "lon"=>21.1},{"mapid"=>@map.id,"x"=>22,"y"=>33, "lat"=>55.1, "lon"=>55.1}]
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 2, body["data"].size
  end
  
  
end