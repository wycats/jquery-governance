FactoryGirl.define do
  factory :motion do
    member
    sequence(:title) {|n| "motion-#{n}"}
    state_name "waitingsecond"
  end

  factory :voting_motion, :parent => :motion do
    state_name "voting"
  end

  factory :discussing_motion, :parent => :motion do
    state_name "discussing"
  end

  factory :closed_motion, :parent => :motion do
    state_name "closed"
    closed_at  Time.now
  end
end
