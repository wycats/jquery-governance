def factory_name(factory = nil)
  factory ?
    @current_factory_name = factory.gsub(/ /,'_').to_sym :
    @current_factory_name
end

def to_m(name)
  name.gsub(/ /,'_').to_sym
end

# Has the potential to create 3 instance variables for future use
# in the current scenario:
# Example:
#
#   "Given an existing "vehicle" of "type" "car"
#
#   @current = @vehicle = @car = Factory.create(:vehicle, :type => :car)
#
Given /^an existing "([^"]*)" (?:with|of) "([^"]*)" "([^"]*)"$/ do |factory, property, value|
  @current = instance_variable_set(:"@#{factory_name(factory)}", Factory.create(factory_name, property.to_sym => value))

  #I'm sure there's an easier way to create a valid instance variable name
  if value =~ /^[a-zA-Z_]/
    value_name = value.downcase.gsub(/ /, '_').gsub(/\W/,'').underscore 
    instance_variable_set(:"@#{value_name}", @current)
  end
end

Given /^an existing "([^"]*)"$/ do |factory|
  @current = instance_variable_set(:"@#{factory_name(factory)}", Factory.create(factory_name))
end

Given /^with "([^"]*)" "(.*)"$/ do |property, value|
  @current.update_attribute(to_m(property), value)
end

Given /^the motion has (\d+) (second|abstain|vote|yes vote|no vote)s?$/ do |several, event_type|
  several.to_i.times do
    Factory.create(factory_name(event_type), :motion => @motion)
  end
end

Given /^(?:it's) waiting "([^"]*)"$/ do |waiting_on|
  @motion.send(:"waiting#{waiting_on}!")
end

{
  'in the title' => 'h1, h2, h3',
  'in the navigation' => 'nav'
}.
each do |within, selector|
  Then /^(.+) #{within}$/ do |step|
    with_scope(selector) do
      Then step
    end
  end
end
