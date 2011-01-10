require 'spec_helper'

describe Conflict do
  before do
    @conflict = Factory.create(:conflict)
  end

  it "should require a name" do
    @conflict.name = nil
    @conflict.should_not be_valid
  end

  it "should equal a conflict with the same name" do
    @conflict.name = "awesome"
    @new_conflict = Factory.create(:conflict, :name => "awesome")
    @new_conflict.should == @conflict
  end

  it "should return its name when to_s is called" do
    @conflict.name = "cool"
    @conflict.to_s.should == "cool"
  end
end
