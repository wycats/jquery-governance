require 'spec_helper'

describe Conflict do
  before do
    @conflict = Factory.create(:conflict)
  end

  it "should have relations with motions" do
    motion = Factory.create(:motion)
    motion.conflicts << @conflict
    motion.conflicts.size.should == 1
    motion.conflicts.first.title.should == @conflict.title
  end

  it "should have relations with members" do
    member = Factory.create(:john_resig)
    member.conflicts << @conflict
    member.conflicts.size.should == 1
    member.conflicts.first.title.should == @conflict.title
  end
end
