require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests  ImportsController
    
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
      post :create, import:{name: "new import", metadata: import_one_file}

    end
    assert_redirected_to import_path(Import.last)
    import = Import.last
    assert "new import", import.name
    assert 1, import.file_count
  end

  test "udpate" do
    patch :update, {id: @import.id, import: {name:"changed name"}}
   
    assert_redirected_to @import
    assert "changed name", @import.name    
  end
  
  test "show" do

    get :show, :id => @import.id
    assert_response :ok
    assert_select 'h2', 'Import: test import' 
  end
  
  test "index" do
    get :index
    assert_response :ok
    
    assert_select "tr", 2  #two tr the thead row and the import
    assert_select 'a[href=?]', import_path(@import), { text: @import.name }
  end
  
  test "start" do
    Import.any_instance.stubs(:import!).returns(true)
    patch :start , :id => @import.id
    assert_response :ok
    assert_select "h2", "Importing..."
  end

  test "delete" do
    assert_difference('Import.count', -1) do
      delete :destroy, :id => @import.id
    end
    assert_redirected_to imports_path
    assert_equal 'Import deleted!', flash[:notice]
  end

  test "maps" do
    map = FactoryGirl.create(:basic_map)
    map2 = FactoryGirl.create(:unstubbed_map)
    @import.maps << [map, map2]
    get :maps, :id => @import.id
    assert_response :ok
    
    assert_select "tr", 3  #two tr the thead row and the import
   
    assert_select 'a[href=?]', map_path(map), { text: map.title }

  end
end
