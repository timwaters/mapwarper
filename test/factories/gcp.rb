FactoryGirl.define do
  
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
  
end