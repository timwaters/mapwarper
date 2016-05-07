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
  
  class SingleMapTest < MapsControllerTest
    
    def cleanup_images(map)
      if File.exists?(map.temp_filename)
        File.delete(map.temp_filename)
      end
      if File.exists?(map.warped_filename)
        File.delete(map.warped_filename)
      end
      if File.exists?(map.warped_png_filename)
        File.delete(map.warped_png_filename)
      end
      if File.exists?(map.warped_png_filename+".aux.xml")
        File.delete(map.warped_png_filename+".aux.xml")
      end
      
    end
    
    def cleanup_gml(map)
      if File.exists?(map.masking_file_gml)
        File.delete(map.masking_file_gml)
      end
      if File.exists?(map.masking_file_gml+".ol")
        File.delete(map.masking_file_gml+".ol")
      end
      if File.exists?(map.masking_file_gfs)
        File.delete(map.masking_file_gfs)
      end
    end
    
    test "get a map" do
      get :show, :id => @map.id, :format => :json
      # puts response.body.inspect
      assert_response :success
      assert_not_nil assigns(:map)
    end 

    test "get map with bbox" do
      get :show, :id => @warped_map.id, :format => :json
      assert_response :success
      assert_not_nil assigns(:map)
      body = JSON.parse(response.body)
      assert_not_nil body["data"]["attributes"]["bbox"]
      assert_equal body["data"]["attributes"]["bbox"], @warped_map.bbox
    end

    #  test "get map in geojson format" do skip end
    test "get map gcps" do
      gcp_1 = FactoryGirl.create(:gcp_1, :map => @warped_map)
      FactoryGirl.create(:gcp_2, :map => @warped_map)
      FactoryGirl.create(:gcp_3, :map => @warped_map)
      get :gcps, :id => @warped_map.id, :format => :json
      assert_response :success
      body = JSON.parse(response.body)
      assert_equal 3, body["data"].length
      first = body["data"][0]["attributes"]
      assert_equal @warped_map.id, first["map-id"]
      assert_equal gcp_1.x , first["x"]
    end
    
    test "update map when not pemitted" do
      skip
      #sign in  
      #update
      #get error
    end

    test "create map" do
    
      assert_difference('Map.count', 1) do
        post 'create', :format => :json, 'map' => {'title' => "new map"}
      end
      assert_response :created
      body = JSON.parse(response.body)
      assert_equal "new map", body["data"]["attributes"]["title"]
    end

    test "create map from wiki" do
      # 51038 =   http://commons.wikimedia.beta.wmflabs.org/wiki/File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg
      get_api_response_file = File.new(File.join(Rails.root, "/test/fixtures/data/new_from_wiki.txt")) 
      stub_request(:get, "http://commons.wikimedia.beta.wmflabs.org/w/api.php?action=query&format=json&iiprop=url%7Cmime&iiurlwidth=100&pageids=51038&prop=imageinfo").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(get_api_response_file)

      get_image_response_file = File.new(File.join(Rails.root, "/test/fixtures/data/get_image_from_wiki.txt"))  
      stub_request(:get, "http://upload.beta.wmflabs.org/wikipedia/commons/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(get_image_response_file)
    
      assert_difference('Map.count', 1) do
        post 'create',  :format => :json, 'map' => {'title' => "new map", "page_id"=> "51038"}
      end
      assert_response :created
      body = JSON.parse(response.body)
      attribs = body["data"]["attributes"]
    
      assert_equal "File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg", attribs["title"]
      assert_equal "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg/100px-Lawrence-h-slaughter-collection-of-english-maps-england.jpeg", attribs["thumb-url"]
      assert_equal "http://upload.beta.wmflabs.org/wikipedia/commons/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg", attribs["image-url"]
      assert_equal "available",attribs["status"]
    end
    
    
    test "update map" do
      params = {:id => @map.id, :format => :json, 'map' => {'title' => 'foojson'}}
      patch 'update', params
      assert_response :success
      body = JSON.parse(response.body)
      assert_equal "foojson", body["data"]["attributes"]["title"]
    end
   
    test "delete map" do   
      Map.any_instance.stubs(:delete_images).returns(true)
      assert_difference('Map.count', -1) do
        delete 'destroy',:id => @map.id
      end
      assert_response :success
    end
    
    test "rectify no gcps" do
      patch :rectify, :id => @warped_map.id, :format => :json, :warp => 1
      assert_response :unprocessable_entity
      body = JSON.parse(response.body)
      assert body["error"].include?("3 control points")
    end
    
    test "rectify" do
      assert_equal :available, @map.status
      gcp_1 = FactoryGirl.create(:gcp_1, :map => @map)
      FactoryGirl.create(:gcp_2, :map => @map)
      FactoryGirl.create(:gcp_3, :map => @map)
      patch :rectify, :id => @map.id, :format => :json, :warp => 1
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "warped", body["data"]["attributes"]["status"] 
      
      #cleanup from test
      cleanup_images(@map)
    end
    
    #          post   'mask'   => 'mask'
    #          delete 'mask'   => 'delete_mask'
    #          patch  'crop'   => 'crop'
    #          patch  'mask_rectify' => 'crop_and_rectify'
    
    test "save_mask" do
      test_gml = File.join(Rails.root, "/test/fixtures/data/",  @warped_map.id.to_s) + ".gml"
      Map.any_instance.stubs(:masking_file_gml).returns(test_gml)

      assert !File.exists?(test_gml)
      output = '<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>'
      
      post 'mask', :id => @warped_map.id, :format => :json, :output => output
      assert_response :ok
      assert File.exists?(test_gml)
      
      #cleanup
      cleanup_gml(@warped_map)
    end

    test "delete_mask" do
      test_gml = File.join(Rails.root, "/test/fixtures/data/",  @warped_map.id.to_s) + ".gml"
      Map.any_instance.stubs(:masking_file_gml).returns(test_gml)

      output = '<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>'
      post 'mask', :id => @warped_map.id, :format => :json, :output => output
      assert_response :ok
      assert File.exists?(test_gml)
      
      delete 'delete_mask', :id => @warped_map.id, :format => :json
      assert_response :ok
      
      assert !File.exists?(test_gml)
      
      body = JSON.parse(response.body)
      assert_equal "unmasked", body["data"]["attributes"]["mask-status"] 
      cleanup_images(@map)
    end
     
    
    #clip (apply mask)
    test "clip_mask" do
      test_gml = File.join(Rails.root, "/test/fixtures/data/", "test") + ".gml"
      Map.any_instance.stubs(:masking_file_gml).returns(test_gml)
      test_gfs = File.join(Rails.root, "/test/fixtures/data/", "test") + ".gfs"
      Map.any_instance.stubs(:masking_file_gfs).returns(test_gfs)

      patch 'crop', :id =>@warped_map.id, :format => :json
      assert_response :ok
            
      body = JSON.parse(response.body)
      assert_equal "masked", body["data"]["attributes"]["mask-status"] 
    end
    
    #clip and rectify apply and warp
    test "mask_crop_rectify" do      
      FactoryGirl.create(:gcp_1, :map => @map)
      FactoryGirl.create(:gcp_2, :map => @map)
      FactoryGirl.create(:gcp_3, :map => @map)
      
      assert_equal :available, @map.status
      assert_equal :unmasked, @map.mask_status
      output = '<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>'
      patch 'mask_crop_rectify', :id => @map.id, :format => :json, :output => output
      assert_response :ok
            
      body = JSON.parse(response.body)
      assert_equal "masked", body["data"]["attributes"]["mask-status"] 
      assert_equal "warped", body["data"]["attributes"]["status"] 
      
      #cleanup
      cleanup_images(@map)
      cleanup_gml(@map)
    end
    
    test "publish" do
      assert_equal :warped, @warped_map.status
      patch "publish", :id => @warped_map.id, :format => :json
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "published", body["data"]["attributes"]["status"] 
    end
    
    test "unpublish" do
      @warped_map.status = :published
      @warped_map.save
      patch "unpublish", :id => @warped_map.id, :format => :json
      assert_response :ok   
      body = JSON.parse(response.body)
      assert_equal "warped", body["data"]["attributes"]["status"] 
    end
    
    test "get_status" do
      get "status", :id =>@map.id, :format => :json
      assert_response :ok   
      assert_equal @map.status.to_s, response.body
    end

    
    #get layers
  
  end

  class CollectionMapTest < MapsControllerTest  
    setup do
      @index_maps = FactoryGirl.create_list(:index_map, 5)
    end

    test "layers maps" do
      layer = FactoryGirl.create(:layer_with_maps)
      get :index, :layer_id => layer.id, :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal 1, body["data"].length
    end
    
    test "get list of maps" do
      get :index, :foo=>"bar", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal 7, body["data"].length
    end
    
    test "search maps" do
      get :index, :query=>"title", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal 2, body["data"].length
      assert_equal "title", body["data"][0]["attributes"]["title"]
    end

    test "sort maps" do
      get :index, :sort_order => "asc", :sort_key => "title", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal 7, body["data"].length
      assert_equal @index_maps.first.title, body["data"][0]["attributes"]["title"]
      assert_equal "title", body["data"][6]["attributes"]["title"]

      get :index, :sort_order => "desc", :sort_key => "title", :format => :json
      assert_response :success
      body = JSON.parse(response.body)
      assert_equal 7, body["data"].length
      assert_equal @index_maps.first.title, body["data"][6]["attributes"]["title"]
      assert_equal "title", body["data"][0]["attributes"]["title"]
    end
    
    test "sort and query maps" do
      get :index, :query => "map", :sort_order => "asc", :sort_key => "title", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal 5, body["data"].length
      assert_equal @index_maps.first.title, body["data"][0]["attributes"]["title"]
      assert_equal @index_maps.last.title, body["data"][4]["attributes"]["title"]
    end

    test "get warped" do
      get :index, :show_warped => "1", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal 1, body["data"].length
      assert_equal "title", body["data"][0]["attributes"]["title"]
      assert_equal "warped", body["data"][0]["attributes"]["status"]
    end   
    
    test "geosearch" do
      #intersects: POLYGON((26.779899697812 58.421402710855, 26.779213052304 58.328018921793, 26.849250894101 58.329392212808, 26.849937539609 58.422089356363, 26.779899697812 58.421402710855))
      #bbox = 26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855
      
      #within: POLYGON((26.633644204648 58.428269165933, 26.63295755914 58.302613038003, 26.859550576718 58.301239746988, 26.85886393121 58.428955811441, 26.633644204648 58.428269165933))
      #bbox = 26.633644204648, 58.302613038003, 26.859550576718, 58.428269165933
      #this bbox intersects our map intersects (but does not encompass it)
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :operation => "intersect", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal "title", body["data"][0]["attributes"]["title"]
      assert_equal "warped", body["data"][0]["attributes"]["status"]
      
      #within, so expect 0
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :operation => "within", :format => :json
      assert_response :success
      assert_empty assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal [], body["data"]
      
      # now with the bbox that encompasses it all
      
      get :index, :bbox => "26.633644204648, 58.302613038003, 26.859550576718, 58.428269165933", :operation => "intersect", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal "title", body["data"][0]["attributes"]["title"]
      assert_equal "warped", body["data"][0]["attributes"]["status"]
      
      #within, so expect 0
      get :index, :bbox => "26.633644204648, 58.302613038003, 26.859550576718, 58.428269165933", :operation => "within", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal "title", body["data"][0]["attributes"]["title"]
      assert_equal "warped", body["data"][0]["attributes"]["status"]
      
    end
    
    test "geosearch with query" do
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :query =>"title",:operation => "intersect", :format => :json
      assert_response :success
      assert_not_nil assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal "title", body["data"][0]["attributes"]["title"]
      assert_equal "warped", body["data"][0]["attributes"]["status"]
      
      get :index, :bbox => "26.849937539609, 58.328018921793, 26.779899697812, 58.421402710855", :query =>"map",:operation => "intersect", :format => :json
      assert_response :success
      assert_empty assigns(:maps)
      body = JSON.parse(response.body)
      assert_equal [], body["data"]
      
    end
    

  
  end
  
end
