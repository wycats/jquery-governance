FactoryGirl.define do 
  factory :conflict do 
    sequence(:title) {|n| "Conflict-#{n}"}
  end
end
