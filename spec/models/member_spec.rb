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
