FactoryGirl.define do

  factory :import do
    name "test"
  end

  factory :batch_import, :parent => :import do
    name "batch test"
  end

end
