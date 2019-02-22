FactoryGirl.define do


  factory :import do
    name "test import"
    metadata { File.new(Rails.root.join('test/fixtures/data/imports/import_one.csv'))}
  end

end
