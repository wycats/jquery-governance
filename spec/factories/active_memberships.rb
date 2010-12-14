FactoryGirl.define do
  factory :active_membership do
    association :member, :factory => :john_resig
    association :qualifying_motion, :factory => :closed_motion
  end

  factory :expired_membership, :parent => :active_membership do
    ended_at 2.days.ago
    association :qualifying_motion, :factory => :closed_motion, :closed_at => 4.days.ago
  end

  factory :future_membership, :parent => :active_membership do
    started_at 2.days.from_now
  end

  factory :active_admin_membership, :parent => :active_membership do
    association :member, :factory => :admin_member
  end

  factory :active_non_admin_membership, :parent => :active_membership do
    association :member, :factory => :non_admin_member
  end
end
