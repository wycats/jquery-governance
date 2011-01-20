FactoryGirl.define do
  factory :motion_confliction, :class => :confliction do
    conflict
    association :conflictable, :factory => :motion
  end

  factory :member_confliction, :class => :confliction do
    conflict
    association :conflictable, :factory => :member
  end
end
