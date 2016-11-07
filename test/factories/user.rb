FactoryGirl.define do

  factory :user, :class => User do
    login "user"
    email "test@example.com"
    password "password"
    password_confirmation "password"
    confirmed_at Date.today
  end
  
  factory :admin, :class => User do
    login "admin"
    email "admin@example.com"
    password "password"
    password_confirmation "password"
    confirmed_at Date.today
    after(:create) do | u |
      admin_role = FactoryGirl.create(:admin_role)
      u.roles << admin_role
    end
  end
  
  factory :editor, :class => User do
    login "editor"
    email "editor@example.com"
    password "password"
    password_confirmation "password"
    confirmed_at Date.today
    after(:create) do | u |
      admin_role = FactoryGirl.create(:editor_role)
      u.roles << admin_role
    end
  end

end
