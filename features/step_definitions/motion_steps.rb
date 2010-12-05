Given /^a motion titled "([^"]*)" exists$/ do |title|
  Factory(:motion, title: title)
end


