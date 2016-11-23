FactoryGirl.define do

  factory :import do
    name "test"
    save_layer true
  end

  factory :tartu_import, :parent => :import do
    name "Category:Maps_Of_Tartu"
  end

end
