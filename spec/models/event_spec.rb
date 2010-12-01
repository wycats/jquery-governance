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

    it "should pass a vote only when yea requirements are met" do
      motion  = Factory.create(:motion)

      8.times { Factory.create(:active_membership) }
      4.times { Factory.create(:yes_vote, :motion => motion) }

      motion.passed?.should be_false

      Factory.create(:yes_vote, :motion => motion)

      motion.passed?.should be_true
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

      lambda { Factory.create(:second, :member => member) }.should raise_exception
    end

    it "should scope seconds for a motion" do
      motion  = Factory.create(:motion)
      4.times { Factory.create(:second, :motion => motion) }

      motion.events.seconds.count.should == 4
    end
  end
end
