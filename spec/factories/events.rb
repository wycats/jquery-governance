FactoryGirl.define do
  factory :event do
    member { Factory(:membership).member }
  end

  factory :yes_vote, :parent => :event do
    event_type "yes_vote"
    association :motion, :factory => :voting_motion
  end

  factory :no_vote, :parent => :event do
    event_type "no_vote"
    association :motion, :factory => :voting_motion
  end

  factory :second, :parent => :event do
    event_type "second"
    motion
  end

  factory :objection, :parent => :event do
    event_type "objection"
    association :motion, :factory => :discussing_motion
  end

  factory :withdrawn, :parent => :event do
    event_type "withdrawn"
    motion
  end

end
