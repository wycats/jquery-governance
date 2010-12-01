require 'spec_helper'

describe ActiveMembership do
  describe "self.active_at" do
    describe "when there active memberships and expried memberships" do
      before do
        @active_membership = Factory.create(:active_membership)
        @expired_membership = Factory.create(:expired_membership)
      end

      it "knows that active memberships exist" do
        ActiveMembership.active_at(Time.now).should_not be_empty
      end

      it "returns the membership that is active" do
        ActiveMembership.active_at(Time.now).should include(@active_membership)
      end

      it "excludes the expired membership" do
        ActiveMembership.active_at(Time.now).should_not include(@expired_membership)
      end
    end

    describe "when all memberships are expired" do
      before do
        @expired_memberships = Factory.create(:expired_membership)
      end

      it "knows there are no active memberships" do
        ActiveMembership.active_at(Time.now).should be_empty
      end
    end

    describe "when a there is a membership that has no end time" do
      before do
        @infinite_membership = Factory.create(:active_membership)
      end

      it "knows that it is currently active" do
        ActiveMembership.active_at(Time.now).should include(@infinite_membership)
      end

      it "knows that it will always be active" do
        ActiveMembership.active_at(500.days.from_now).should include(@infinite_membership)
      end
    end

    describe "when there is a membership that has yet to start" do
      before do
        @future_membership = Factory.create(:future_membership)
      end

      it "knows that it isn't currently active" do
        ActiveMembership.active_at(Time.now).should_not include(@future_membership)
      end

      it "knows that it will be active 5 days from now" do
        ActiveMembership.active_at(5.days.from_now).should include(@future_membership)
      end
    end
  end

  describe "self.members_active_at" do
    before do
      @member = Factory.create(:active_membership).member
      @expired_member = Factory.create(:expired_membership).member
    end

    it "includes the members that have a currently active membership" do
      ActiveMembership.members_active_at(Time.now).should include(@member)
    end

    it "excludes members without an active membership" do
      ActiveMembership.members_active_at(Time.now).should_not include(@expired_member)
    end

    describe "when a memeber has overlapping active memberships" do
      before do
        @member.active_memberships << Factory.create(:active_membership, :member => @member)
      end

      it "includes the member without repeating him" do
        ActiveMembership.members_active_at(Time.now).uniq!.should be_nil
      end
    end
  end
end
