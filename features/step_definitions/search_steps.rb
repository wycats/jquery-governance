Given /^I fill in "([^"]*)" for my search terms/ do |terms|
  fill_in(:keywords, :with => terms)
end
