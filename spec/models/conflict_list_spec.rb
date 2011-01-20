require 'spec_helper'

describe ConflictList do
  before :all do
    @conflict_list = ConflictList.new("build", "create")
  end

  it "should be able to be add a new conflict" do
    @conflict_list.add("cool")
    @conflict_list.include?("cool").should be_true
  end

  it "should be able to add delimited lists of words" do
    @conflict_list.add("cool, wicked", :parse => true)
    @conflict_list.include?("cool").should be_true
    @conflict_list.include?("wicked").should be_true
  end

  it "should be able to add delimited list of words with quoted delimiters" do
    @conflict_list.add("'cool, wicked', \"really cool, really wicked\"", :parse => true)
    @conflict_list.include?("cool, wicked").should be_true
    @conflict_list.include?("really cool, really wicked").should be_true
  end

  it "should be able to handle other uses of quotation marks correctly" do
    @conflict_list.add("john's cool car, mary's wicked toy", :parse => true)
    @conflict_list.include?("john's cool car").should be_true
    @conflict_list.include?("mary's wicked toy").should be_true
  end

  it "should be able to add an array of words" do
    @conflict_list.add(["cool", "wicked"], :parse => true)
    @conflict_list.include?("cool").should be_true
    @conflict_list.include?("wicked").should be_true
  end
end
