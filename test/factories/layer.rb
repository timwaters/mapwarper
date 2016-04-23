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
        
    end
 
  end
  
end