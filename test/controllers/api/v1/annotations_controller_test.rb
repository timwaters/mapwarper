require 'test_helper'

class AnnotationsControllerTest < ActionController::TestCase

  include Devise::Test::ControllerHelpers
  tests  Api::V1::AnnotationsController
  class NormalUserTest < AnnotationsControllerTest

  setup do
    @map =  FactoryGirl.create(:warped_map)
    @user = FactoryGirl.create(:user)
    @annotation =    FactoryGirl.create(:annotation_1, :map => @map, :user => @user)
    @annotation_2 =    FactoryGirl.create(:annotation_2, :map => @map,  :user => @user)
    @annotation_3 =    FactoryGirl.create(:annotation_3, :map => @map,  :user => @user)
      
    request.env["devise.mapping"] = Devise.mappings[:user] 
    sign_in @user 
  end

  test "show" do
    get 'show', :id  => @annotation.id
    assert_response :ok
    assert_not_nil assigns(:annotation)
    body = JSON.parse(response.body)
    assert_equal @annotation.id, body["data"]["id"].to_i
  end

  test "create with no body or geom" do
    assert_difference('Annotation.count', 0) do
      post 'create', 'data' => {'type' => "annotations", "attributes"=>{"body"=>"", "geom"=> "POINT (144.205 -38.3389)"}}
    end
    assert_response :unprocessable_entity
    assert response.body.include?("body")

    assert_difference('Annotation.count', 0) do
      post 'create', 'data' => {'type' => "annotations", "attributes"=>{"body"=>"casascasc", "geom"=> ""}}
    end
    assert_response :unprocessable_entity
    assert response.body.include?("geom")
  end

  test "create" do
    assert_difference('Annotation.count', 1) do
      post 'create', 'data' => {'type' => "annotations","attributes"=>{"body"=>"Newly created", "geom"=> "POINT (144.205 -38.3389)", :map_id => @map.id}}
    end
    assert_response :created
    body = JSON.parse(response.body)

    assert_equal "Newly created", body["data"]["attributes"]["body"]
    assert_equal @map.id, body["data"]["attributes"]["map"]["id"].to_i
  end


  test "update" do
    patch "update", :id => @annotation.id, 'data' => {'type' => "annotations", "attributes"=>{"body"=>"updated body"}}
    assert_response :ok
    
    body = JSON.parse(response.body)
    assert_equal "updated body", body["data"]["attributes"]["body"]
  end

  test "destroy not allowed by normal user" do
    assert_difference('Annotation.count', 0) do
      delete 'destroy', :id => @annotation.id
    end
    assert_response :unauthorized
    
    body = JSON.parse(response.body)
  
    assert body["errors"][0]["title"].include?("Unauthorized")
  end

  test "simple index" do
    get 'index'
    assert_response :ok
    assert_not_nil assigns(:annotations)
    body = JSON.parse(response.body)
    assert_equal 3, body["data"].size
  end


  test "search" do
    get 'index', :query => "herald"
    assert_response :ok
    assert_not_nil assigns(:annotations)
    body = JSON.parse(response.body)
    assert_equal 2, body["data"].size
  end

end

  class AdminTest < AnnotationsControllerTest
    
    setup do 
      admin_sign_in

      @map =  FactoryGirl.create(:warped_map)
      @user = FactoryGirl.create(:user)
      @annotation =    FactoryGirl.create(:annotation_1, :map => @map, :user => @user)
      @annotation_2 =    FactoryGirl.create(:annotation_2, :map => @map, :user => @admin_user)
    end

    test "admin can destroy" do
      assert_difference('Annotation.count', -1) do
        delete 'destroy', :id => @annotation.id
      end
      assert_response :ok
    
      body = JSON.parse(response.body)
      assert_equal @annotation.id, body["data"]["id"].to_i
    end

    test "annotation destroyed when user is delete" do
      assert_difference('Annotation.count', -1) do
        @user.destroy
      end
    end
  

  end
 

end
