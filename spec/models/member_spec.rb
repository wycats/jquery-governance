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
        5.times { Factory.create(:active_membership, :member => Factory.create(:member)) }
      end

      it "can see a motion that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'approved' state" do
        @motion.approved!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'failed' state" do
        @motion.failed!
        @member.can?(:see, @motion).should be_true
      end

      it "can't vote a motion that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:vote, @motion).should be_false
      end

      it "can vote a motion that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:vote, @motion).should be_true
      end

      it "can't vote more than once on a motion that is in the 'voting' state" do
        # Since we are not testing Motion#vote, stub it out, to just return a yes vote
        @motion.stub(:vote).and_return(Factory(:yes_vote, :motion => @motion, :member => @member))
        @motion.voting!
        @motion.vote(@member, true)
        @motion.voting?.should be_true
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion in the 'voting' state if there's a conflict of interest" do
        @motion.stub(:conflicts_with_member?).with(@member).and_return(true)
        @motion.voting!
        @member.can?(:vote, @motion).should be_false
      end

      it "can vote a motion that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:vote, @motion).should be_true
      end

      it "can't vote more than once on a motion that is in the 'passed' state" do
        # Since we are not testing Motion#vote, stub it out, to just return a yes vote
        @motion.stub(:vote).and_return(Factory(:yes_vote, :motion => @motion, :member => @member))
        @motion.passed!
        @motion.vote(@member, true)
        @motion.passed?.should be_true
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion in the 'passed' state if there's a conflict of interest" do
        @motion.stub(:conflicts_with_member?).with(@member).and_return(true)
        @motion.passed!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion in the 'approved' state" do
        @motion.approved!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion in the 'failed' state" do
        @motion.failed!
        @member.can?(:vote, @motion).should be_false
      end

      it "can second a motion from another active member that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @member.can?(:second, @motion).should be_true
      end

      it "can't second more than once on a motion from another active member that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @motion.second(@member)
        @motion.waitingsecond?.should be_true
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'waiting second' state if it was made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.waitingsecond!
        @member.can?(:second, @motion).should be_false
      end

      it "can second a motion from another active member that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @member.can?(:second, @motion).should be_true
      end

      it "can't second more than once on a motion from another active member that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @motion.second(@member)
        @motion.waitingexpedited?.should be_true
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'waiting expedited' state if it was made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.waitingexpedited!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'waiting objection' state made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.waitingobjection!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'objected' state made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.objected!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'voting' state made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.voting!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'passed' state made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.passed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'approved' state" do
        @motion.approved!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'approved' state made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.approved!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'failed' state" do
        @motion.failed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'failed' state made by him or her" do
        @motion = Factory.create(:motion, :member => @member)
        @motion.failed!
        @member.can?(:second, @motion).should be_false
      end
    end

    describe "an inactive member" do
      before do
        @member = Factory.create(:expired_membership).member
        @motion = Factory.create(:motion)
      end

      it "can't see a motion that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @member.can?(:see, @motion).should be_false
      end

      it "can't see a motion that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @member.can?(:see, @motion).should be_false
      end

      it "can't see a motion that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:see, @motion).should be_false
      end

      it "can't see a motion that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:see, @motion).should be_false
      end

      it "can see a motion that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'approved' state" do
        @motion.approved!
        @member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'failed' state" do
        @motion.failed!
        @member.can?(:see, @motion).should be_true
      end

      it "can't vote a motion that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'approved' state" do
        @motion.approved!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'failed' state" do
        @motion.failed!
        @member.can?(:vote, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'approved' state" do
        @motion.approved!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'failed' state" do
        @motion.failed!
        @member.can?(:second, @motion).should be_false
      end
    end
  end

  describe "has_voted_on?" do
    it "knows if the member has voted on the specified motion" do
      @motion = Factory(:motion)
      @member = Factory(:member)
      Factory(:yes_vote, :motion => @motion, :member => @member)
      @member.has_voted_on?(@motion).should be_true
    end
  end

  describe "has_voted_on?" do
    it "knows if the member has voted on the specified motion" do
      @motion = Factory(:motion)
      @member = Factory(:member)
      Factory(:second, :motion => @motion, :member => @member)
      @member.has_seconded?(@motion).should be_true
    end
  end
end
