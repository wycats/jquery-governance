FactoryGirl.define do
  factory :event do
    member
    motion
  end

  factory :yes_vote, :parent => :event do
    event_type "yes_vote"
  end

  factory :no_vote, :parent => :event do
    event_type "no_vote"
  end

  factory :second, :parent => :event do
    event_type "second"
  end

  factory :objection, :parent => :event do
    event_type "objection"
  end
end
