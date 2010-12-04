require 'spec_helper'

describe Event do

  before :all do
      @motion  = Factory.create(:motion)
      @member  = Factory.create(:active_membership).member
      @vote = Factory.create(:yes_vote)
      @second_vote = Factory.create(:yes_vote)
      @no_vote = Factory.create(:no_vote)
      @second = Factory.create(:second)
      @second_second = Factory.create(:second)
  end

  it "should know which of the events are votes" do
    Event.votes.should == ([@vote, @second_vote, @no_vote])
  end

  it "should know which of the events are seconds" do
    Event.seconds.should == ([@second, @second_second])
  end

  it "knows how many of the votes are yeas" do
    Event.votes.yeas.count.should == 2
  end

  it "knows how many of the votes are nays" do
    Event.votes.nays.count.should == 1
  end

  describe "a vote" do
    it "knows that it is a vote" do
      @vote.should be_vote
    end

    it "knows that it isn't a second" do
      @vote.should_not be_second
    end
  end

  describe "a second" do
    it "knows that it is a second" do
      @second.should be_second
    end

    it "knows that it isn't a vote" do
      @second.should_not be_vote
    end
  end

  it "should not allow a member to vote twice on a motion" do
    Factory.create(:yes_vote, :motion => @motion, :member => @member).should raise_exception
  end

  it "should prevent a motion's author from seconding that motion" do
    Factory.create(:second, :motion => @motion, :member => @member).should raise_exception
  end

  describe "Objecting" do
    pending "Objection process needs specs"
  end

  describe "Event Collisions" do
    pending "Member activity for a given Motion should not override Events of differing type, unless they are in conflict"
    pending "Members should be able to override (negate) prior votes, but only within the given motion-event's timeframe"
  end
end
