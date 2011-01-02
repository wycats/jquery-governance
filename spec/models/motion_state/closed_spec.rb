require 'spec_helper'

module MotionState
  describe Closed do
    before(:all) do
      @active_member = Factory(:membership).member
      @inactive_member = Factory(:expired_membership).member
      @motion = Factory(:closed_motion)
      @motion_state = @motion.state
    end

    describe "setup" do
      it "should notify members of the outcome of the motion now that it is closed" do
        ActiveMemberNotifier.should_receive(:deliver).with(:motion_closed, @motion)
        @motion_state.setup
      end
    end

    describe "permit?" do
      it "allows an active member to see the motion" do
        @motion_state.permit?(:see, @active_member).should be_true
      end

      it "allows an inactive member to see the motion" do
        @motion_state.permit?(:see, @inactive_member).should be_true
      end

      it "doesn't allow an active member to object the motion" do
        @motion_state.permit?(:object, @active_member).should be_false
      end

      it "doesn't allow an inactive member to object the motion" do
        @motion_state.permit?(:object, @inactive_member).should be_false
      end

      it "doesn't allow an active member to vote the motion" do
        @motion_state.permit?(:vote, @active_member).should be_false
      end

      it "doesn't allow an inactive member to vote the motion" do
        @motion_state.permit?(:vote, @inactive_member).should be_false
      end

      it "doesn't allows an active member to second another member's motion" do
        @motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an active member to second its own motion" do
        @owned_motion_state = Factory(:closed_motion, :member => @active_member).state
        @owned_motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an inactive member to second the motion" do
        @motion_state.permit?(:second, @inactive_member).should be_false
      end
    end

    it "responds to schedule_updates" do
      @motion_state.should respond_to(:schedule_updates)
    end

    it "responds to update" do
      @motion_state.should respond_to(:update)
    end

    it "responds to scheduled_update" do
      @motion_state.should respond_to(:scheduled_update)
    end
  end
end
