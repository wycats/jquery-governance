FactoryGirl.define do
  factory :active_membership do 
    association :member, :factory => :john_resig
    start_time 4.days.ago
    end_time nil
  end

  factory :expired_membership, :parent => :active_membership do
    end_time 2.days.ago
  end

  factory :future_membership, :parent => :active_membership do
    start_time 2.days.from_now
  end
end
