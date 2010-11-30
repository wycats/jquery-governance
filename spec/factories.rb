Factory.sequence :motion_title do |n|
  "motion-#{n}"
end

Factory.define :event do |event|
  event.member
  event.motion
  event.type { "vote" }
end

Factory.define :member do |member|
  member.name "Member"
end
 
Factory.define :motion do |motion|
 motion.member 
 motion.title Factory.next(:motion_title)
end
