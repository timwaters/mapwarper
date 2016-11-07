FactoryGirl.define do
  
  factory :layer, :class => Layer do
    name "name"
    description "description"
    
    
    factory :layer_with_maps do
       
      after(:create) do |layer|
        map1 =  FactoryGirl.create(:available_map)
        layer.maps << map1
      end
        
    end
    
    factory :layer_with_warped_maps do
       
      after(:create) do |layer|
        map1 =  FactoryGirl.create(:warped_map)
        layer.maps << map1
      end
      
      bbox_geom  RGeo::Cartesian::factory.parse_wkt("POLYGON ((26.64563925009777 58.341507605975615, 26.825994866513525 58.341507605975615, 26.825994866513525 58.4058083040021, 26.64563925009777 58.4058083040021, 26.64563925009777 58.341507605975615))")
      bbox  "26.64563925009777,58.341507605975615,26.825994866513525,58.4058083040021"
        
    end
    
    factory :index_layer, :parent => :layer do
      sequence :name do |n|
        "layer #{n}"
      end
      sequence :description do | n|
        "layer_desc #{n}"
      end
    end
 
  end
  
end