Given /^a motion titled "([^"]*)" exists(?: in the "(.*)" state)?$/ do |title, state_name|
  if state_name.blank? || state_name == 'waitingsecond'
    state_name = :motion
  else
    state_name = :"#{state_name}_motion"
  end
  Factory(state_name, title: title)
end

Given /^a approved motion titled "([^"]*)"$/ do |title|
  motion = Factory(:voting_motion, title: title)
  10.times { Factory(:yes_vote, motion: motion) }
  motion.closed!
end

Then /^the motion titled "([^"]*)" is in discussion$/ do |title|
  Motion.find_by_title!(title).should be_discussing
end

Then /^the motion titled "([^"]*)" is being voted$/ do |title|
  Motion.find_by_title!(title).should be_voting
end

Then /^the motion titled "([^"]*)" should be closed$/ do |title|
  Motion.find_by_title!(title).should be_closed
end

Then /^the motion titled "([^"]*)" is approved$/ do |title|
  Motion.find_by_title!(title).should be_approved
end

Then /^the motion titled "([^"]*)" fails$/ do |title|
  Motion.find_by_title!(title).should be_failed
end

And /^a (?:dis)?qualifying motion exists with the reference number "([^"]*)"$/ do |id|
  Factory.create(:closed_motion, :id => id)
end
