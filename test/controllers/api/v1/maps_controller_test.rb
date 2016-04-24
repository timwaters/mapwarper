require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  Api::V1::MapsController
  
  setup do

  end
  
  test "should get index" do
    get :index
    puts response.body.inspect
    assert_response :success
    assert_not_nil assigns(:maps)
  end
  
end