
Given /an? existing "([^"]*)"(?: with "([^"]*)" "([^"]*)")/ do |factory_name, attribute, value|

  factory                 = factory_name.to_sym

  new_item                = Factory.create(factory)

  instance_variable_set("@#{factory_name}".to_sym, new_item)
  instance_variable_set("@#{attribute}".to_sym,    new_item) if attribute && attribute =~ /^[a-zA-Z_]/
  instance_variable_set("@#{value}".to_sym,        new_item) if value && value =~ /^[a-zA-Z_]/
end

When /I press Remove/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  page.click('Remove')
end

Then /^I should see an? "([^"]*)" submit button$/ do |title|
    page.should have_no_xpath("//button[@value='#{title}']")
end

Then /^I should not see an? "([^"]*)" submit button$/ do |title|
  page.should have_no_xpath("//button[@value='#{title}']")
end

Then /^I should get a "(\d+)" response$/ do |status|
  page.status_code.should == status.to_i
end



# Use semantic sections as a shortcut to add contextual
# suffix selectors to your steps.
#
#Example:
#
#  semantic_suffixes({ 'in the title' => 'h1' })
#
#  allows you to use:
#
#  Then I should see "some text" in the title
#  which is effectively:
#
#  Then I should see "some text" within "h1"
#
def semantic_suffixes(semantic_to_selector_hash)
  semantic_to_selector_hash.each do |within, selector|
    Then /^(.+) #{within}$/ do |step|
      with_scope(selector) do
        Then step
      end
    end
  end
end

semantic_suffixes({
  'in the title' => 'h1',
  'in the navigation' => 'nav'
})
