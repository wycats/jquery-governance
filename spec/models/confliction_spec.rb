require 'spec_helper'

describe Confliction do
  before(:each) do
    @confliction = Factory.build(:member_confliction)
  end

  it "should not be valid with a invalid conflict" do
    @confliction.conflictable = Factory.create(:member)
    @confliction.conflict = nil

    @confliction.should_not be_valid
  end

  it "should not create duplicate conflictions" do
    @conflictable = Factory.create(:motion)
    @conflict = Factory.create(:conflict)

    lambda {
      2.times { Confliction.create( :conflictable => @conflictable, :conflict => @conflict) }
    }.should change(Confliction, :count).by(1)
  end
end
