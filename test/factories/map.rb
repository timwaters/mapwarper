FactoryGirl.define do
  #available_map
  #unloaded_map
  #warped_map

  #maps with layers

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
    
     after(:create) do |m|
       FactoryGirl.create(:gcp_1, :map => m)
       FactoryGirl.create(:gcp_2, :map => m)
       FactoryGirl.create(:gcp_3, :map => m)
     end

  end
  
  factory :available_map, :parent => :inited_map do
    status :available
  end
  
  factory :warped_map, :parent => :inited_map do
    status :warped
  end
  
  factory :gcp, :class => Gcp do
  
    factory :gcp_1 do
      x 51.5
      y 27.7
      lat 58.380
      lon 26.737    
    end
    
    factory :gcp_2 do
      x 13.0
      y 61.5
      lat 58.353
      lon 26.679    
    end
    
    factory :gcp_3 do
      x 78.7
      y 35.7
      lat 58.372
      lon 26.784   
    end
  end
  
  #Layer / Mosaic


end
