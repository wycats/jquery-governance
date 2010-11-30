Factory.sequence :motion_title do |n|
  "motion-#{n}"
end

Factory.sequence :email do |n|
  "member#{n}@example.com"
end

Factory.define :second do |second|
  second.member
  second.motion
end

Factory.define :member do |member|
  member.name  "Member"
  member.email { Factory.next(:email) }
  member.password "password"
end
 
Factory.define :motion do |motion|
 motion.member 
 motion.title { Factory.next(:motion_title) }
end
