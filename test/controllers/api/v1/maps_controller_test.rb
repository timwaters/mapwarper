require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::MapsController
  
  setup do
    @map = FactoryGirl.create(:available_map)
    @warped_map = FactoryGirl.create(:warped_map)
    request.env["devise.mapping"] = Devise.mappings[:user] 
    #sign_in FactoryGirl.create(:user) 

  end
  
  test "should get maps" do
    get :index, :format => :json
    puts response.body#.inspect
    assert_response :success
    assert_not_nil assigns(:maps)
  end

  test "should get a map" do
    get :show, :id => @map.id, :format => :json
    puts response.body.inspect
    assert_response :success
    assert_not_nil assigns(:map)
  end
  
end
