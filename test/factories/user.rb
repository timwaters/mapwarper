FactoryGirl.define do

  factory :user, :class => User do
    login "user"
    email "test@example.com"
    password "password"
    password_confirmation "password"
    confirmed_at Date.today
  end

end
