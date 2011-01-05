semantic_suffixes('in the list of tags' => '#tags li')

Given /^these tags exist:$/ do |table|
  table.rows.each do |(name)|
    Factory.create(:tag, name: name)
  end
end
