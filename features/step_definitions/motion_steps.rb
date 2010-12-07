Given /^a motion titled "([^"]*)" exists(?: in the "(.*)" state)?$/ do |title, state|
  Factory(:motion, title: title, state: state)
end
