require 'spec_helper'

describe Member do
  before :all do
    @member = Factory.create(:active_membership).member
    @inactive_member = Factory.create(:expired_membership).member

    @admin_member = Factory.create(:active_admin_membership).member
    @non_admin_member = Factory.create(:active_non_admin_membership).member

    @renewed_member = Factory.create(:active_membership).member
    Factory.create(:expired_membership, :member => @renewed_member)

    @expired_member = Factory.create(:expired_membership, :started_at => 2.years.ago, :ended_at => 8.months.ago).member
    Factory.create(:expired_membership, :member => @expired_member, :started_at => 5.months.ago, :ended_at => 4.days.ago)

    @motion = Factory.create(:motion)
    @member_motion = Factory.create(:motion, :member => @member)
  end

  describe "active_at?" do
    describe "a currently active member" do

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
      it "knows that it is not active today" do
        @inactive_member.should_not be_active_at(Time.now)
        @inactive_member.should_not be_membership_active
      end

      it "knows it is not active before the start time" do
        @inactive_member.should_not be_active_at(20.days.ago)
      end

      it "is not active after the end time" do
        @inactive_member.should_not be_active_at(20.days.from_now)
      end
    end

    describe "a reactivated member who is active now" do
      it "knows that it is active today" do
        @renewed_member.should be_active_at(Time.now)
        @renewed_member.should be_active
      end

      it "knows it is not active between the two activity times" do
        @renewed_member.should_not be_active_at(1.month.ago)
      end

      it "knows it is not active before the start time" do
        @renewed_member.should_not be_active_at(3.years.ago)
      end

      it "knows it is still active in the future" do
        @renewed_member.should be_active_at(20.days.from_now)
      end
    end

    describe "a reactivated member who has been deactivated again" do
      before :all do
      end

      it "knows that it is not active today" do
        @expired_member.should_not be_active_at(Time.now)
        @expired_member.should_not be_membership_active
      end

      it "knows it is active in the second active period" do
        @expired_member.should be_active_at(4.months.ago)
      end

      it "knows it is not active between the two activity times" do
        @expired_member.should_not be_active_at(7.months.ago)
      end

      it "knows it is not active before the start time" do
        @expired_member.should_not be_active_at(3.years.ago)
      end

      it "knows it is not active in the future" do
        @expired_member.should_not be_active_at(1.month.from_now)
      end
    end
  end

  describe "can?" do
    describe "an active member" do
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
        debugger
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
        @motion.stub(:required_votes => 1)
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
        @member_motion.waitingsecond!
        @member.can?(:second, @member_motion).should be_false
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
        @member_motion.waitingexpedited!
        @member.can?(:second, @member_motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'waiting objection' state made by him or her" do
        @member_motion.waitingobjection!
        @member.can?(:second, @member_motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'objected' state" do
        @motion.objected!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'objected' state made by him or her" do
        @member_motion.objected!
        @member.can?(:second, @member_motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'voting' state" do
        @motion.voting!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'voting' state made by him or her" do
        @member_motion.voting!
        @member.can?(:second, @member_motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'passed' state" do
        @motion.passed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'passed' state made by him or her" do
        @member_motion.passed!
        @member.can?(:second, @member_motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'approved' state" do
        @motion.approved!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'approved' state made by him or her" do
        @member_motion.approved!
        @member.can?(:second, @member_motion).should be_false
      end

      it "can't second a motion from another active member that is in the 'failed' state" do
        @motion.failed!
        @member.can?(:second, @motion).should be_false
      end

      it "can't second a motion in the 'failed' state made by him or her" do
        @member_motion.failed!
        @member.can?(:second, @member_motion).should be_false
      end

      context "that is an admin" do
        it "can destroy other members" do
          @admin_member.can?(:destroy, @member).should be_true
        end
      end
      context "that is not an admin" do
        it "cannot destroy other members" do
          @non_admin_member.can?(:destroy, @member).should be_false
        end
      end
    end

    describe "an inactive member" do
      it "can't see a motion that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @inactive_member.can?(:see, @motion).should be_false
      end

      it "can't see a motion that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @inactive_member.can?(:see, @motion).should be_false
      end

      it "can't see a motion that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @inactive_member.can?(:see, @motion).should be_false
      end

      it "can't see a motion that is in the 'objected' state" do
        @motion.objected!
        @inactive_member.can?(:see, @motion).should be_false
      end

      it "can see a motion that is in the 'voting' state" do
        @motion.voting!
        @inactive_member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'passed' state" do
        @motion.passed!
        @inactive_member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'approved' state" do
        @motion.approved!
        @inactive_member.can?(:see, @motion).should be_true
      end

      it "can see a motion that is in the 'failed' state" do
        @motion.failed!
        @inactive_member.can?(:see, @motion).should be_true
      end

      it "can't vote a motion that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'objected' state" do
        @motion.objected!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'voting' state" do
        @motion.voting!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'passed' state" do
        @motion.passed!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'approved' state" do
        @motion.approved!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't vote a motion that is in the 'failed' state" do
        @motion.failed!
        @inactive_member.can?(:vote, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'waiting second' state" do
        @motion.waitingsecond!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'waiting expedited' state" do
        @motion.waitingexpedited!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'waiting objection' state" do
        @motion.waitingobjection!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'objected' state" do
        @motion.objected!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'voting' state" do
        @motion.voting!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'passed' state" do
        @motion.passed!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'approved' state" do
        @motion.approved!
        @inactive_member.can?(:second, @motion).should be_false
      end

      it "can't second a motion from an active member that is in the 'failed' state" do
        @motion.failed!
        @inactive_member.can?(:second, @motion).should be_false
      end
    end
  end

  describe "has_voted_on?" do
    it "knows if the member has voted on the specified motion" do
      @yes_vote = Factory.create(:yes_vote, :member => @member, :motion => @motion)
      @member.has_voted_on?(@motion).should be_true
    end
  end

  describe "has_voted_on?" do
    it "knows if the member has voted on the specified motion" do
      @second = Factory.create(:second, :member => @member, :motion => @motion)
      @member.has_seconded?(@motion).should be_true
    end
  end

  describe "#destroy" do
    it "keeps the record around by setting a 'deleted_at' flag" do
      @member.destroy
      Member.only_deleted.first.deleted_at.should be
    end
  end
end
