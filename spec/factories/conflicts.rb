FactoryGirl.define do
  factory :conflict do
    sequence(:name) {|n| "Conflict-#{n}"}
  end
end
