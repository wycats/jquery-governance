require 'spec_helper'

describe Membership do

  describe "qualifying and disqualifying memberships with motions" do
    before do
      @motion = Factory.create(:motion)
      @membership = Factory.create(:membership)
    end

    it "requires that a qualifying motion be specified when creating a new membership" do
      @membership.qualifying_motion = nil
      @membership.should_not be_valid
    end

    describe "qualified_by" do
      it "returns the motion that qualified the current active membership" do
        @membership.qualifying_motion = @motion
        @membership.qualified_by.should == @motion
      end
    end

    describe "disqualified_by" do
      it "returns the motion that disqualified the current active membership" do
        @membership.disqualifying_motion = @motion
        @membership.disqualified_by.should == @motion
      end
    end
  end

  describe "setting start timestamp on create" do
    before do
      @motion = Factory.create(:motion, :closed_at => 2.days.ago)
    end

    context "when the started_at has been not set explicitly" do
      it 'sets started_at to the closed_at time of the qualifying motion' do
        attrs_for_membership = Factory.attributes_for(:membership)
        attrs_for_membership[:qualifying_motion_id] = @motion.id

        membership = Membership.new( attrs_for_membership )
        membership.save

        membership.started_at.should eql @motion.closed_at
      end
    end
  end

  describe "self.expired" do
    describe "when there active memberships and expried memberships" do
      before do
        @membership = Factory.create(:membership)
        @expired_membership = Factory.create(:expired_membership)
      end

      it "knows that one of the memberships is expired" do
        Membership.expired.should_not be_empty
      end

      it "returns the membership that is expired" do
        Membership.expired.should include(@expired_membership)
      end

      it "excludes the active membership" do
        Membership.expired.should_not include(@membership)
      end
    end

    describe "when all memberships are active" do
      before do
        @membership = Factory.create(:membership)
      end

      it "knows there are no expired memberships" do
        Membership.expired.should be_empty
      end
    end

    describe "when a there is a membership that has no end time" do
      before do
        @infinite_membership = Factory.create(:membership)
      end

      it "knows that it is not expired" do
        Membership.expired.should_not include(@infinite_membership)
      end
    end

    describe "when there is a membership that has yet to start" do
      before do
        @future_membership = Factory.create(:future_membership)
      end

      it "knows that it isn't expired" do
        Membership.expired.should_not include(@future_membership)
      end
    end
  end

  describe "self.active_at" do
    describe "when there active memberships and expried memberships" do
      before do
        @membership = Factory.create(:membership)
        @expired_membership = Factory.create(:expired_membership)
      end

      it "knows that active memberships exist" do
        Membership.active_at(Time.now).should_not be_empty
      end

      it "returns the membership that is active" do
        Membership.active_at(Time.now).should include(@membership)
      end

      it "excludes the expired membership" do
        Membership.active_at(Time.now).should_not include(@expired_membership)
      end
    end

    describe "when all memberships are expired" do
      before do
        @expired_memberships = Factory.create(:expired_membership)
      end

      it "knows there are no active memberships" do
        Membership.active_at(Time.now).should be_empty
      end
    end

    describe "when a there is a membership that has no end time" do
      before do
        @infinite_membership = Factory.create(:membership)
      end

      it "knows that it is currently active" do
        Membership.active_at(Time.now).should include(@infinite_membership)
      end

      it "knows that it will always be active" do
        Membership.active_at(500.days.from_now).should include(@infinite_membership)
      end
    end

    describe "when there is a membership that has yet to start" do
      before do
        @future_membership = Factory.create(:future_membership)
      end

      it "knows that it isn't currently active" do
        Membership.active_at(Time.now).should_not include(@future_membership)
      end

      it "knows that it will be active 5 days from now" do
        Membership.active_at(5.days.from_now).should include(@future_membership)
      end
    end
  end

  describe "self.members_active_at" do
    before do
      @member = Factory.create(:membership).member
      @expired_member = Factory.create(:expired_membership).member
    end

    it "includes the members that have a currently active membership" do
      Membership.members_active_at(Time.now).should include(@member)
    end

    it "excludes members without an active membership" do
      Membership.members_active_at(Time.now).should_not include(@expired_member)
    end

    describe "when a memeber has overlapping active memberships" do
      before do
        @member.memberships << Factory.create(:membership, :member => @member)
      end

      it "includes the member without repeating him" do
        Membership.members_active_at(Time.now).uniq!.should be_nil
      end
    end
  end
end
