require 'spec_helper'

module MotionState
  describe Waitingsecond do
    describe "setup" do
      it "should notify members of that a new motion has been created" do
        @motion = Factory.build(:motion)
        ActiveMemberNotifier.should_receive(:deliver).with(:motion_created, @motion)
        @motion.save
      end
    end

    describe "permit?" do
      before(:all) do
        @active_member = Factory(:membership).member
        @inactive_member = Factory(:expired_membership).member
        @motion = Factory(:motion)
        @motion_state = @motion.state
      end

      it "allows an active member to see the motion" do
        @motion_state.permit?(:see, @active_member).should be_true
      end

      it "doesn't allow an inactive member to see the motion" do
        @motion_state.permit?(:see, @inactive_member).should be_false
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

      it "allows an active member to second another member's motion" do
        @motion_state.permit?(:second, @active_member).should be_true
      end

      it "doesn't allow an active member to second more than once another member's motion" do
        @active_member.second(@motion)
        @motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an active member to second its own motion" do
        @owned_motion_state = Factory(:motion, :member => @active_member).state
        @owned_motion_state.permit?(:second, @active_member).should be_false
      end

      it "doesn't allow an inactive member to second the motion" do
        @motion_state.permit?(:second, @inactive_member).should be_false
      end
    end

    describe "schedule_updates" do
      it "should schedule an update in 48 hours" do
        @motion = Factory(:motion)
        @motion_state = @motion.state
        ScheduledMotionUpdate.should_receive(:in).with(48.hours, @motion)
        @motion_state.schedule_updates
      end
    end

    describe "update" do
      describe "for a non expedited motion" do
        before do
          @motion = Factory(:motion)
          @motion_state = @motion.state
        end

        it "updates the motion state to 'discussing' for a motion with 2 seconds" do
          @motion.stub(:seconds_count => 2)
          @motion_state.update
          @motion.should be_discussing
        end

        it "doesn't update the motion state for a motion with less than 2 seconds" do
          @motion.stub(:seconds_count => 1)
          @motion_state.update
          @motion.should be_waitingsecond
        end
      end

      describe "for an expedited motion" do
        before do
          @motion = Factory(:motion, :expedited => true)
          @motion_state = @motion.state
        end

        it "updates the motion state to 'voting' for a motion with enough seconds" do
          @motion.stub(:seconds_count => 4, :seconds_for_expedition => 4)
          @motion_state.update
          @motion.should be_voting
        end

        it "doesn't update the motion state for a motion with less than the needed seconds" do
          @motion.stub(:seconds_count => 3, :seconds_for_expedition => 4)
          @motion_state.update
          @motion.should be_waitingsecond
        end
      end
    end

    describe "scheduled_update" do
      describe "for a non expedited motion" do
        before :all do
          @motion = Factory(:motion)
          @motion_state = @motion.state
          @member = Factory(:membership).member
        end

        it "doesn't update the motion state before 48 hours" do
          @motion_state.scheduled_update(47.hours)
          @motion.should be_waitingsecond
        end

        context "when the motion fails to get at least 2 seconds in 48 hours" do

          before :all do
            @member.second(@motion)
          end

          it "updates the motion state to 'closed'" do
            @motion_state.scheduled_update(48.hours)
            @motion.should be_closed
          end
        end

      end

      describe "for an expedited motion" do
        before do
          @motion = Factory(:motion, :expedited => true)
          @motion_state = @motion.state
        end

        it "doesn't update the motion state before 48 hours" do
          @motion_state.scheduled_update(47.hours)
          @motion.should be_waitingsecond
        end

        it "updates the motion state to 'discussing' for a motion with 2 or more seconds after 48 hours" do
          @motion.stub(:seconds_count => 2)
          @motion_state.scheduled_update(48.hours)
          @motion.should be_discussing
        end

        it "updates the motion state to 'closed' for a motion with less than 2 seconds after 48 hours" do
          @motion.stub(:seconds_count => 1)
          @motion_state.scheduled_update(48.hours)
          @motion.should be_closed
        end
      end
    end
  end
end
