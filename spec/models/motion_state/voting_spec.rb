require 'spec_helper'

module MotionState
  describe Voting do
    describe "permit?" do
      before(:all) do
        @active_member = Factory(:active_membership).member
        @inactive_member = Factory(:expired_membership).member
        @motion = Factory(:voting_motion)
        @motion_state = @motion.state
      end

      it "allows an active member to see the motion" do
        @motion_state.permit?(:see, @active_member).should be_true
      end

      it "allows an inactive member to see the motion" do
        @motion_state.permit?(:see, @inactive_member).should be_true
      end

      it "allows an active member to vote the motion" do
        @motion_state.permit?(:vote, @active_member).should be_true
      end

      it "doesn't allow an active member to vote the motion more than once" do
        @motion.stub(:vote).and_return(Factory(:yes_vote, :motion => @motion, :member => @active_member))
        @motion.vote(@active_member, true)
        @motion_state.permit?(:vote, @active_member).should be_false
      end

      it "doesn't allow an active member to vote the motion if there's a conflict of interest" do
        @motion.stub(:conflicts_with_member?).with(@active_member).and_return(true)
        @motion_state.permit?(:vote, @active_member).should be_false
      end

      it "doesn't allow an inactive member to vote the motion" do
        @motion_state.permit?(:vote, @inactive_member).should be_false
      end

      it "doesn't allow an active member to second another member's motion" do
        @motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an active member to second its own motion" do
        @owned_motion_state = Factory(:voting_motion, :member => @active_member).state
        @owned_motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an inactive member to second the motion" do
        @motion_state.permit?(:second, @inactive_member).should be_false
      end
    end

    describe "schedule_updates" do
      it "should schedule an update in 48 hours" do
        @motion = Factory(:voting_motion)
        @motion_state = @motion.state
        ScheduledMotionUpdate.should_receive(:in).with(48.hours, @motion)
        @motion_state.schedule_updates
      end
    end

    it "responds to update" do
      Factory(:voting_motion).state.should respond_to(:update)
    end

    describe "scheduled_update" do
      before do
        @motion = Factory(:voting_motion)
        @motion_state = @motion.state
      end

      describe "a motion that has the mayority of the votes" do
        before { @motion.stub(:has_met_requirement? => true) }

        it "doesn't update the motion state before 48 hours" do
          @motion_state.scheduled_update(47.hours)
          @motion.should be_voting
        end

        it "updates the motion state to 'closed' after 48 hours" do
          @motion_state.scheduled_update(48.hours)
          @motion.should be_closed
        end
      end

      describe "a motion that doesn't have the mayority of the votes" do
        before { @motion.stub(:has_met_requirement? => false) }

        it "doesn't update the motion state before 48 hours" do
          @motion_state.scheduled_update(47.hours)
          @motion.should be_voting
        end

        it "updates the motion state to 'closed' after 48 hours" do
          @motion_state.scheduled_update(48.hours)
          @motion.should be_closed
        end
      end
    end
  end
end
