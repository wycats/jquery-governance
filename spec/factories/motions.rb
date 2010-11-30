FactoryGirl.define do 
  factory :motion do 
    member
    sequence(:title) {|n| "motion-#{n}"}
  end
end
