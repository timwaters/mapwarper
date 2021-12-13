FactoryGirl.define do
  
  factory :annotation, :class => Annotation do
    
    factory :annotation_1 do
      body "This is the first annotation #hark #herald"
      geom  "POINT (146.205 -38.338)"
    end

    factory :annotation_2 do
      body "This is the second annotation #herald #angels"
      geom  "POINT (144.205 -38.3389)"
    end

    factory :annotation_3 do
      body "This is the third annotation #angels #sing"
      geom  "POINT (143.205 -38.3389)"
    end

    factory :annotation_polygon do
      body "This is the fourth polygon annotation #carol"
      geom "POLYGON ((145.126-37.987, 145.016 -38.1192, 145.2196 -38.1302, 145.126-37.987))"
    end
    

    
  end
  
end