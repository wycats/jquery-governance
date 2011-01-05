FactoryGirl.define do
  factory :membership do
    association :member, :factory => :john_resig
    association :qualifying_motion, :factory => :closed_motion, :closed_at => 4.days.ago
  end

  factory :expired_membership, :parent => :membership do
    association :disqualifying_motion, :factory => :closed_motion, :closed_at => 2.days.ago
  end

  factory :future_membership, :parent => :membership do
    association :qualifying_motion, :factory => :closed_motion, :closed_at => 2.days.from_now
  end

  factory :active_admin_membership, :parent => :membership do
    association :member, :factory => :admin_member
    is_admin true
  end

  factory :active_non_admin_membership, :parent => :membership do
    association :member, :factory => :non_admin_member
    is_admin true
  end
end
