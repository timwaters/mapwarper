FactoryGirl.define do

  factory :basic_map, :class => Map do
    title "title"
    description "description" 
  end
  
  factory :unstubbed_map, :parent => :basic_map do
    upload { File.new(Rails.root.join('test', 'fixtures', 'data', '100x70map.png')) }
  end
  
  #stub initial conversion (loading up via paperclip, conversion to tiff)
  factory :inited_map, :parent => :basic_map do
    upload_file_name { '100x70map.png' }
    upload_content_type { 'image/png' }
    upload_file_size { 12811 }
    status :available

    after(:build) { | map |
      map.stubs(:setup_image).returns(true)
      map.stubs(:save_dimensions).returns(:available)
    
      map.filename = "100x70map.png.tif" # set during setup_image
      map.width = 100 # set during save_dims
      map.height = 70 # set during save_dims
    }
    
    #to create gcps at same time   
    #     after(:create) do |m|
    #       FactoryGirl.create(:gcp_1, :map => m)
    #       FactoryGirl.create(:gcp_2, :map => m)
    #       FactoryGirl.create(:gcp_3, :map => m)
    #     end

  end
  
  factory :available_map, :parent => :inited_map do
    status :available
  end
  
  factory :warped_map, :parent => :inited_map do
    status :warped
    bbox_geom  RGeo::Cartesian::factory.parse_wkt("POLYGON ((26.64563925009777 58.341507605975615, 26.825994866513525 58.341507605975615, 26.825994866513525 58.4058083040021, 26.64563925009777 58.4058083040021, 26.64563925009777 58.341507605975615))")
    bbox  "26.64563925009777,58.341507605975615,26.825994866513525,58.4058083040021"
  end
 
  #Layer / Mosaic

end
