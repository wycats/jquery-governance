FactoryGirl.define do
  factory :motion do
    member
    sequence(:title) {|n| "motion-#{n}"}
    state_name "waitingsecond"
  end
end
