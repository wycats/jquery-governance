FactoryGirl.define do
  factory :active_membership do
    association :member, :factory => :john_resig
    started_at 4.days.ago
    ended_at nil
  end

  factory :expired_membership, :parent => :active_membership do
    ended_at 2.days.ago
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
