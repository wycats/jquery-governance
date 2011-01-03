require 'spec_helper'

describe Member do
  before :all do
    @motion = Factory.create(:closed_motion)
    @member = Factory.create(:membership, :qualifying_motion => @motion).member
    @inactive_member = Factory.create(:expired_membership).member

    @admin_member = Factory.create(:active_admin_membership).member
    @non_admin_member = Factory.create(:active_non_admin_membership).member

    @renewed_member = Factory.create(:membership).member
    Factory.create(:expired_membership, :member => @renewed_member)

    @expired_member = Factory.create(:expired_membership).member
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

  describe "vote" do
    it "creates a new vote with the given member and value" do
      current_motion = Factory.create(:motion)
      voting_member  = Factory.create(:membership).member

      voting_member.vote(current_motion, true)
      Event.votes.last.member.should eql voting_member
      Event.votes.last.value.should be_true
    end
  end

  describe "has_voted_on?" do
    it "knows if the member has voted on the specified motion" do
      @yes_vote = Factory.create(:yes_vote, :member => @member, :motion => @motion)
      @member.has_voted_on?(@motion).should be_true
    end
  end

  describe "membership_active?" do
    it "returns true if the member has an active membership" do
      @member.membership_active?.should be_true
    end

    it "return false if the member has no active memberships" do
      @expired_member.membership_active?.should be_false
    end
  end

  describe "name_or_email" do
    context "when the name of the member is known" do
      it "reutrns the name of the member" do
        @member.name_or_email.should == @member.name
      end
    end

    context "when the name of the member isn't known" do
      it "returns the email address of the member" do
        @member.name = nil
        @member.name_or_email.should == @member.email
      end
    end
  end
end
