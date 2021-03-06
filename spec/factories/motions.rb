FactoryGirl.define do
  factory :motion do
    member
    sequence(:title) {|n| "motion-#{n}"}
    sequence(:description) {|n| "description #{n}"}
    state_name "waitingsecond"
  end

  factory :voting_motion, :parent => :motion do
    state_name "voting"
    public true
  end

  factory :discussing_motion, :parent => :motion do
    state_name "discussing"
  end

  factory :closed_motion, :parent => :motion do
    state_name "closed"
    public true
    closed_at  Time.now
  end
end
