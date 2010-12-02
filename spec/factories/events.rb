FactoryGirl.define do
  factory :event do
    member
    motion
  end

  factory :vote, :parent => :event do
    event_type "vote"
  end

  factory :yes_vote, :parent => :vote  do
    value true
  end

  factory :no_vote, :parent => :vote do
    value false
  end

  factory :second, :parent => :event do
    event_type "second"
  end
end
