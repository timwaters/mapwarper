FactoryGirl.define do

  factory :admin_role, :class => Role do
    name :administrator
  end
  
  factory :editor_role, :class => Role do
    name :editor
  end
  
end