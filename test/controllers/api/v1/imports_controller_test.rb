require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::ImportsController
    
  setup do
    @user = FactoryGirl.create(:editor)
    request.env["devise.mapping"] = Devise.mappings[:editor] 
    sign_in @user 
    @import = FactoryGirl.create(:tartu_import, :user => @user, :uploader_user_id => @user.id)
    #@import.uploader_user_id = @user.id
    #@import.save
    get_category_response_file = File.new(File.join(Rails.root, "/test/fixtures/data/get_category_from_wiki.txt"))
    stub_request(:get, "http://commons.wikimedia.beta.wmflabs.org/w/api.php?action=query&format=json&prop=categoryinfo&titles=Category:Maps_Of_Tartu").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(get_category_response_file)
  end
 
  test "create" do
  
    assert_difference('Import.count', 1) do
      get :create, :import => {:category => "Category:Maps_Of_Tartu", :save_layer => true}
    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal 2, body["data"]["attributes"]["file-count"]
    assert_equal "ready", body["data"]["attributes"]["status"]
    assert_equal "Category:Maps_Of_Tartu", body["data"]["attributes"]["category"]
    assert_equal 0, body["data"]["relationships"]["maps"]["data"].size
  end
 
  test "udpate" do
    get_foo_category_response_file = File.new(File.join(Rails.root, "/test/fixtures/data/get_foo_category_from_wiki.txt"))
    stub_request(:get, "http://commons.wikimedia.beta.wmflabs.org/w/api.php?action=query&format=json&prop=categoryinfo&titles=Category:foo").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(get_foo_category_response_file)

    patch :update, :id => @import.id, :import => {:category => "Category:foo"}
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal 0, body["data"]["attributes"]["file-count"]
  end
  
  test "show" do

    get :show, :id => @import.id
    assert_response :ok
    
    body = JSON.parse(response.body)
    assert_equal 2, body["data"]["attributes"]["file-count"]
    assert_equal "ready", body["data"]["attributes"]["status"]
    assert_equal "Category:Maps_Of_Tartu", body["data"]["attributes"]["category"]
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
    map = FactoryGirl.create(:available_map)
    map2 = FactoryGirl.create(:warped_map)
    @import.maps << [map, map2]
    get :maps, :id => @import.id
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 2, body["data"].size
    
    assert_equal "maps", body["data"][0]["type"]
    assert_equal map.title, body["data"][0]["attributes"]["title"]
  end
  #  maps
end
