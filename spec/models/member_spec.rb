require 'spec_helper'

describe Member do
  describe "active_at?" do
    describe "a currently active member" do
      before do
        @member = Factory.create(:active_membership).member
      end

      it "knows that it is active today" do
        @member.should be_active_at(Time.now)
        @member.should be_active
      end

      it "knows it is not active before the start time" do
        @member.should_not be_active_at(20.days.ago)
      end

      it "is still active in the future if there is no end time" do
        @member.should be_active_at(20.days.from_now)
      end
    end

    describe "an inactive member" do
      before do
        @member = Factory.create(:active_membership, :ended_at => 2.days.ago).member
      end

      it "knows that it is not active today" do
        @member.should_not be_active_at(Time.now)
        @member.should_not be_membership_active
      end

      it "knows it is not active before the start time" do
        @member.should_not be_active_at(20.days.ago)
      end

      it "is not active after the end time" do
        @member.should_not be_active_at(20.days.from_now)
      end
    end

    describe "a reactivated member who is active now" do
      before do
        Factory.create(:active_membership, :started_at => 2.years.ago, :ended_at => 1.year.ago)
        @member = Factory.create(:active_membership, :started_at => 2.days.ago).member
      end

      it "knows that it is active today" do
        @member.should be_active_at(Time.now)
        @member.should be_active
      end

      it "knows it is not active between the two activity times" do
        @member.should_not be_active_at(1.month.ago)
      end

      it "knows it is not active before the start time" do
        @member.should_not be_active_at(3.years.ago)
      end

      it "knows it is still active in the future" do
        @member.should be_active_at(20.days.from_now)
      end
    end

    describe "a reactivated member who has been deactivated again" do
      before do
        Factory.create(:active_membership, :started_at => 2.years.ago, :ended_at => 1.year.ago)
        @member = Factory.create(:active_membership, :started_at => 6.months.ago, :ended_at => 3.months.ago).member
      end

      it "knows that it is not active today" do
        @member.should_not be_active_at(Time.now)
        @member.should_not be_membership_active
      end

      it "knows it is active in the second active period" do
        @member.should be_active_at(4.months.ago)
      end

      it "knows it is not active between the two activity times" do
        @member.should_not be_active_at(7.months.ago)
      end

      it "knows it is not active before the start time" do
        @member.should_not be_active_at(3.years.ago)
      end

      it "knows it is not active in the future" do
        @member.should_not be_active_at(1.month.from_now)
      end
    end
  end

  describe "can?" do
    describe "an active member" do
      before do
        @member = Factory.create(:active_membership).member
        @motion = Factory.create(:motion)
      end

      it "can see a motion that hasn't been brought to a vote" do
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that has been brought to a vote" do
        @motion.voting!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that has been closed" do
        @motion.approved!
        @member.can?(:see, @motion).should be_true
      end

      it "can vote a motion that has been brought to a vote" do
        @motion.voting!
        @member.can?(:vote, @motion).should be_true
      end

      it "can't vote more than once on a motion that has been brought to vote" do
        #Since we are not testing Motion#vote, stub it out, to just return a yes vote  
        @motion.stub(:vote).and_return(Factory(:yes_vote, :motion => @motion, :member => @member))
        
        @motion.voting!
        @motion.vote(@member, true)
        @member.can?(:vote, @motion).should be_false
      end

      context "voting and conflicts of interest" do
        it "can't vote on a motion if he has conflicts of interest associated with this motion" do
          @motion.stub(:conflicts_with_member).with(@member).and_return(true)
          @member.can?(:vote, @motion).should be_false
        end
      end

      it "can't vote a motion that hasn't been brought to a vote" do
        @member.can?(:vote, @motion).should be_false
      end

      it "can second other user's motion that hasn't been brought to vote" do
        @member.can?(:second, @motion).should be_true
      end

      it "can't second other user's motion that hasn't been brought to vote more than once" do
        @motion.second(@member)
        @member.can?(:second, @motion).should be_false
      end

      it "can't second other user's motion that has been brought to vote" do
        @motion.voting!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second other user's motion that has been closed" do
        @motion.failed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second his o her own motion" do
        @motion = Factory.create(:motion, :member => @member)
        @member.can?(:second, @motion).should be_false
      end
    end

    describe "an inactive member" do
      before do
        @member = Factory.create(:expired_membership).member
        @motion = Factory.create(:motion)
      end

      it "can't see a motion that hasn't been brought to a vote" do
        @member.can?(:see, @motion).should be_false
      end

      it "can see a motion that has been brought to a vote" do
        @motion.voting!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that has been closed" do
        @motion.approved!
        @member.can?(:see, @motion).should be_true
      end

      it "can't vote a motion that has been brought to a vote" do
        @motion.voting!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that hasn't been brought to a vote" do
        @member.can?(:vote, @motion).should be_false
      end

      it "can't second other user's motion that hasn't been brought to vote" do
        @member.can?(:second, @motion).should be_false
      end

      it "can't second other user's motion that has been brought to vote" do
        @motion.voting!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second other user's motion that has been closed" do
        @motion.failed!
        @member.can?(:second, @motion).should be_false
      end
    end
  end
end
