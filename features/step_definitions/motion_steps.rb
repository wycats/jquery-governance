Given /^a motion titled "([^"]*)" exists(?: in the "(.*)" state)?$/ do |title, state|
  Factory(:motion, title: title, state: state)
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
