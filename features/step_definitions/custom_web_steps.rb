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
#  
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
