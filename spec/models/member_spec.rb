require 'spec_helper'

describe Member do
  before :all do
    @motion = Factory.create(:closed_motion)
    @member = Factory.create(:active_membership, :qualifying_motion => @motion).member
    @inactive_member = Factory.create(:expired_membership).member

    @admin_member = Factory.create(:active_admin_membership).member
    @non_admin_member = Factory.create(:active_non_admin_membership).member

    @renewed_member = Factory.create(:active_membership).member
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
end
