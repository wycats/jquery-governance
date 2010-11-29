FactoryGirl.define do
  factory :active_membership do 
    association :member, :factory => :john_resig
    start_time 4.days.ago
    end_time nil
  end
end
