FactoryGirl.define do
  sequence :motion_title do |n|
    "motion-#{n}"
  end

  factory :member do
    name "Member"
  end
 
  factory :motion do
    member 
    title Factory.next(:motion_title)
  end
end
