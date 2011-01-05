FactoryGirl.define do
  factory :member do
    name "Test Member"
    sequence(:email) {|n| "TestMan#{n}@example.com"}
    password               "secret"
  end

  factory :john_resig, :parent => :member do
    name "John Resig"
  end

  factory :admin_member, :parent => :member do
    name "Admin member"
  end

  factory :non_admin_member, :parent => :member do
    name "Nonadmin member"
  end
end
