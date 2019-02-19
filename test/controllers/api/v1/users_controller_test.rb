require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests  Api::V1::UsersController
    
  setup do
    @user = FactoryGirl.create(:user)
    request.env["devise.mapping"] = Devise.mappings[:user] 
    sign_in @user 
  end
  
  def admin_sign_in
    sign_out @user
    @admin_user = FactoryGirl.create(:admin)
    request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin_user
  end
  
  test "show" do
    get :show, :id => @user.id, :format => :json
    assert_response :success
    assert_not_nil assigns(:user)
    body = JSON.parse(response.body)
    assert_equal @user.login, body["data"]["attributes"]["login"] 
    assert_nil body["data"]["attributes"]["email"] 
  end
  
  test "show as admin" do
    admin_sign_in
    get :show, :id => @user.id, :format => :json
    assert_response :success
    assert_not_nil assigns(:user)
    body = JSON.parse(response.body)
    assert_equal @user.login, body["data"]["attributes"]["login"] 
    assert_not_nil body["data"]["attributes"]["email"] 
    assert_equal @user.email, body["data"]["attributes"]["email"]
    
  end
  
  test "index unauthorized" do
    get :index 
    assert_response :unauthorized
    assert_nil assigns(:users)
  end
    
  test "index authorized" do
    admin_sign_in
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    body = JSON.parse(response.body)
    assert_equal 2, body["data"].size
    assert_equal @admin_user.login, body["data"][0]["attributes"]["login"]
    
    get :index, :field => "login", :query => "user"
    assert_response :success
    assert_not_nil assigns(:users)
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].size
    assert_equal @user.login, body["data"][0]["attributes"]["login"]
    assert_equal @user.email, body["data"][0]["attributes"]["email"]
  end
  
  
  
end