require 'test_helper'

class ActivityControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::ActivityController
  
  #notes auditing is disabled for tests
  
  test "stats" do
    get "stats"
    assert_response :success
  end
  
  test "index" do
    get "index"
    assert_response :success
  end
  
  test "map_index" do
    get "map_index"
    assert_response :success
  end
  
  test "for_user" do
    user = FactoryGirl.create(:user)
    get "for_user", :id => user.id
    assert_response :success
  end
  
  test "for_map" do
    map = FactoryGirl.create(:available_map)
    get "for_map", :id => map.id
    assert_response :success
  end
  
  
end