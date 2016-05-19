FactoryGirl.define do

  factory :import do
    category "test"
    save_layer true
  end

  factory :tartu_import, :parent => :import do
    category "Category:Maps_Of_Tartu"
  end

end
