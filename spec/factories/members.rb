FactoryGirl.define do
  factory :member do
    name "Test Member"
    sequence(:email) {|n| "TestMan#{n}@example.com"}
    password               "secret"
  end

  factory :john_resig, :parent => :member do
    name "John Resig"
  end
end
