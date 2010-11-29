FactoryGirl.define do
  factory :john_resig, :class => Member do 
    name "John Resig"
    sequence(:email) {|n| "TestMan#{n}@example.com"}
    password               "secret"
  end
end
