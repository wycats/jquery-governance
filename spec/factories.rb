FactoryGirl.define do
  sequence :motion_title do |n|
    "motion-#{n}"
  end

  factory :event do
    member
    motion
    type { "vote" }
  end

  factory :member do
    name "Member"
  end
 
  factory :motion do
    member 
    title Factory.next(:motion_title)
  end
end
