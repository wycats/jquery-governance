Given /^a motion titled "([^"]*)" exists(?: in the "(.*)" state)?$/ do |title, state_name|
  state_name = 'waitingsecond' if state_name.blank?
  Factory(:motion, title: title, state_name: state_name)
end

Then /^the motion titled "([^"]*)" is in discussion$/ do |title|
  Motion.find_by_title!(title).should be_discussing
end

Then /^the motion titled "([^"]*)" is being voted$/ do |title|
  Motion.find_by_title!(title).should be_voting
end

Then /^the motion titled "([^"]*)" is approved$/ do |title|
  Motion.find_by_title!(title).should be_approved
end

Then /^the motion titled "([^"]*)" fails$/ do |title|
  Motion.find_by_title!(title).should be_failed
end

And /^a qualifying motion exists with the reference number "([^"]*)"$/ do |id|
  Factory.create(:closed_motion, :id => id)
end
