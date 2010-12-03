require 'spec_helper'

describe Event do
  describe "Voting" do
    it "should create a Voting Event" do
      vote = Factory.create(:vote)
      vote.event_type.should == "vote"
    end

    it "should create a yes vote" do
      vote = Factory.create(:yes_vote)
      vote.event_type.should == "vote"
      vote.value.should         be_true
    end

    it "should create a no vote" do
      vote = Factory.create(:no_vote)
      vote.event_type.should == "vote"
      vote.value.should         be_false
    end

    it "should not allow a member to vote twice on a motion" do
      motion  = Factory.create(:motion)
      member  = Factory.create(:active_membership).member

      Factory.create(:yes_vote, :motion => motion, :member => member).should be_an_instance_of(Event)
      lambda { Factory.create(:yes_vote, :motion => motion, :member => member) }.should raise_exception
    end

    it "should scope votes for a motion" do
      motion  = Factory.create(:motion)
      4.times { Factory.create(:yes_vote, :motion => motion) }

      motion.events.votes.count.should == 4
    end
  end

  describe "Seconding" do
    it "should create a Seconding Event" do
      seconding = Factory.create(:second)
      seconding.event_type.should == "second"
    end

    it "should not allow a member to author a motion and also second that motion" do
      member  = Factory.create(:active_membership).member
      motion  = Factory.create(:motion, :member => member)

      lambda { Factory.create(:second, :motion => motion, :member => member) }.should raise_exception
    end

    it "should bring motion to a vote if expedition threshold has been met" do
      pending "Needs a callback in the Event model."
    end

    it "should scope seconds for a motion" do
      motion  = Factory.create(:motion)
      4.times { Factory.create(:second, :motion => motion) }

      motion.events.seconds.count.should == 4
    end
  end

  describe "Objecting" do
    pending "Objection process needs specs"
  end

  describe "Event Collisions" do
    pending "Member activity for a given Motion should not override Events of differing type, unless they are in conflict"
    pending "Members should be able to override (negate) prior votes, but only within the given motion-event's timeframe"
  end
end
