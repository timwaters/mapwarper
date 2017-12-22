FactoryGirl.define do
  
    factory :warning, :class => UserWarning do
      category "prune"
      note "foo bar"
      user { |u| [u.association(:user)] }
    end
   
  
  end
  