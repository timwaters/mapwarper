require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::ImportsController
    
  setup do
    @user = FactoryGirl.create(:admin)
    request.env["devise.mapping"] = Devise.mappings[:admin] 
    sign_in @user 
    @import = FactoryGirl.create(:import, :user => @user)
    @import.save
  end
 
  test "create" do
  
    assert_difference('Import.count', 1) do
      import_one_file = fixture_file_upload("data/imports/import_one.csv", "text/csv")
      post :create, 'data' => {'type' => "imports", "attributes"=>{:name => "new import", :metadata => import_one_file}}

    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal 1, body["data"]["attributes"]["file_count"]
    assert_equal "ready", body["data"]["attributes"]["status"]
    assert_equal "new import", body["data"]["attributes"]["name"]
    assert_equal 0, body["data"]["relationships"]["maps"]["data"].size
  end
 
  test "udpate" do
    patch :update, :id => @import.id, 'data' => {'type' => "imports", "attributes"=>{:name  => "changed name"}}
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal 1, body["data"]["attributes"]["file_count"]
    assert_equal "changed name", body["data"]["attributes"]["name"]
  end
  
  test "show" do

    get :show, :id => @import.id
    assert_response :ok
    
    body = JSON.parse(response.body)
    assert_equal 1, body["data"]["attributes"]["file_count"]
    assert_equal "ready", body["data"]["attributes"]["status"]
    assert_equal "test import", body["data"]["attributes"]["name"]
  end
  
  test "index" do
    get :index
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].size
  end
  
  test "start" do
    Import.any_instance.stubs(:import!).returns(true)
    patch :start , :id => @import.id
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "running", body["data"]["attributes"]["status"]
  end

  test "delete" do
    assert_difference('Import.count', -1) do
      delete :destroy, :id => @import.id
    end
    assert_response :ok
  end

  test "maps" do
    map = FactoryGirl.create(:basic_map)
    map2 = FactoryGirl.create(:unstubbed_map)
    @import.maps << [map, map2]
    get :maps, :id => @import.id
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 2, body["data"].size
    
    assert_equal "maps", body["data"][0]["type"]
    assert_equal map.title, body["data"][0]["attributes"]["title"]
  end

end
