require 'spec_helper'

module MotionState
  describe Discussing do
    describe "permit?" do
      before(:all) do
        @active_member = Factory(:active_membership).member
        @inactive_member = Factory(:expired_membership).member
        @motion_state = Factory(:discussing_motion).state
      end

      it "allows an active member to see the motion" do
        @motion_state.permit?(:see, @active_member).should be_true
      end

      it "doesn't allow an inactive member to see the motion" do
        @motion_state.permit?(:see, @inactive_member).should be_false
      end

      it "doesn't allow an active member to vote the motion" do
        @motion_state.permit?(:vote, @active_member).should be_false
      end

      it "doesn't allow an inactive member to vote the motion" do
        @motion_state.permit?(:vote, @inactive_member).should be_false
      end

      it "doesn't allow an active member to second another member's motion" do
        @motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an active member to second its own motion" do
        @owned_motion_state = Factory(:discussing_motion, :member => @active_member).state
        @owned_motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an inactive member to second the motion" do
        @motion_state.permit?(:second, @inactive_member).should be_false
      end
    end

    describe "schedule_updates" do
      it "should schedule updates in 24 and 48 hours" do
        @motion = Factory(:discussing_motion)
        @motion_state = @motion.state
        ScheduledMotionUpdate.should_receive(:in).with(24.hours, @motion)
        ScheduledMotionUpdate.should_receive(:in).with(48.hours, @motion)
        @motion_state.schedule_updates
      end
    end

    it "responds to update" do
      Factory(:discussing_motion).state.should respond_to(:update)
    end

    describe "scheduled_update" do
      describe "for a non objected motion" do
        before do
          @motion = Factory(:discussing_motion)
          @motion_state = @motion.state
        end

        it "doesn't update the motion state before 24 hours" do
          @motion_state.scheduled_update(23.hours)
          @motion.should be_discussing
        end

        it "updates the motion state to 'voting' after 24 hours" do
          @motion_state.scheduled_update(24.hours)
          @motion.should be_voting
        end
      end

      describe "for an objected motion" do
        before do
          @motion = Factory(:discussing_motion)
          @motion_state = @motion.state
          @motion.object(Factory(:active_membership).member)
        end

        it "doesn't update the motion state before 48 hours" do
          @motion_state.scheduled_update(47.hours)
          @motion.should be_discussing
        end

        it "updates the motion state to 'voting' after 48 hours" do
          @motion_state.scheduled_update(48.hours)
          @motion.should be_voting
        end
      end
    end
  end
end
