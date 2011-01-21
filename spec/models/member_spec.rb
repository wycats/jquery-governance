require 'spec_helper'

describe Member do
  before :all do
    @motion = Factory.create(:closed_motion)
    @members_membership = Factory.create(:membership, :qualifying_motion => @motion)
    @member = @members_membership.member
    @inactive_member = Factory.create(:expired_membership).member

    @admin_member = Factory.create(:active_admin_membership).member
    @non_admin_member = Factory.create(:active_non_admin_membership).member

    @renewed_members_membership = Factory.create(:membership)
    @renewed_member = @renewed_members_membership.member
    @renewed_members_expired_membership = Factory.create(:expired_membership, :member => @renewed_member)

    @expired_member = Factory.create(:expired_membership).member
    Factory.create(:expired_membership, :member => @expired_member, :started_at => 5.months.ago, :ended_at => 4.days.ago)

    @motion = Factory.create(:motion)
    @member_motion = Factory.create(:motion, :member => @member)
  end

  describe "self.active" do
    it "should return all members who currently have an active membership" do
      Member.active.should include(@member, @admin_member, @non_admin_member, @renewed_member)
    end

    it "should not include members who currently do not have an active membership" do
      Member.active.should_not include(@inactive_member, @expired_member)
    end
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

  describe "active_membership" do
    describe "a currently active member" do
      it "returns its membershp" do
        @member.active_membership.should == @members_membership
      end
    end

    describe "a currently inactive member" do
      it "returns nil" do
        @inactive_member.active_membership.should be_nil
      end
    end

    describe "a member with a renewed membership" do
      it "returns the membership that is active now" do
        @renewed_member.active_membership.should == @renewed_members_membership
      end

      it "shouldn't retrun the member's expired membership" do
        @renewed_member.active_membership.should_not == @renewed_members_expired_membership
      end
    end
  end

  describe "membership_active?" do
    describe "a currently active member" do
      it "returns true" do
        @member.membership_active?.should be_true
      end
    end

    describe "a currently inactive member" do
      it "returns false" do
        @inactive_member.membership_active?.should be_false
      end
    end

    describe "a member with a renewed membership" do
      it "returns true" do
        @renewed_member.membership_active?.should be_true
      end
    end
  end

  describe "is_admin?" do
    describe "an admin member" do
      it "returns true" do
        @admin_member.is_admin?.should be_true
      end
    end

    # describe "an non-admin member" do
    #   @member.is_admin?.should be_false
    # end
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

  describe "second" do
    it "creates a second for the given motion" do
      motion = Factory.create(:motion)
      member = Factory.create(:membership).member

      member.second(motion)
      Event.seconds.last.member.should eql member
      Event.seconds.last.motion.should eql motion
    end
  end

  describe "object" do
    it "creates an objection for the given motion" do
      motion = Factory.create(:discussing_motion)
      member = Factory.create(:membership).member

      member.object(motion)
      Event.objections.last.member.should eql member
      Event.objections.last.motion.should eql motion
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

  describe "conflicts_list" do

    context "when there are no conflicts asociated with the member" do
      it "returns an empty array" do
        @member.conflicts_list.should be_empty
      end
    end

    context "when the member has at least one conflict" do
      before :all do
        @member.conflicts_list = "test"
        @member.save
      end

      it "returns an array of the names of the conflicts that are associated with the member" do
        @member.conflicts_list.should == ["test"]
      end
    end
  end

    def conflicts_with?(conflictable)
      (conflicts_list & conflictable.conflicts_list).empty?
    end

  describe "conflicts_with?" do
    before :each do
      @member = Factory.create(:member)
      @member.conflicts_list = ["conflict", "test"]
      @member.save

      @motion = Factory.create(:motion)
    end

    context "when the member doesn't conflict with the motion" do
      it "returns false" do
        @motion.conflicts_list = ["good", "cool"]
        @motion.save
        @member.conflicts_with?(@motion).should be_false
      end
    end

    context "when the member does conflict with the motion" do
      it "returns true" do
        @motion.conflicts_list = ["test", "cool"]
        @motion.save
        @member.conflicts_with?(@motion).should be_true
      end
    end
  end
  # describe "save_conflicts" do
  #   before :all do
  #     @new_member = Factory.create(:member)
  #     @new_member.conflicts_list = ["conflict", "good", "awesome"]
  #     @new_member.save
  #     @new_member.conflicts_list = ["good", "awesome"]
  #     @new_member.save
  #   end

  #   it "deletes any conflictions that aren't specified in the conflicts_list" do
  #     Member.find(@new_member.id).conflicts.should_not include(Conflict.find_by_name("conflict"))
  #   end

  #   it "creates new conflictions for conflicts that aren't alraedy associated with the user" do
  #     Member.find(@new_member.id).conflicts.should include(Conflict.find_by_name("good"), Conflict.find_by_name("awesome"))
  #   end
  # end
end
