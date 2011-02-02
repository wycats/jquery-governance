require 'spec_helper'

describe ScheduledMotionUpdate do
  describe ".perform" do
    context "for a motion waiting for seconds that hasn't been marked as expedited" do
      before :all do
        @motion = Factory(:motion)
        @motion_state = @motion.state
      end

      it "doesn't update the motion state before 48 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'waitingsecond', 47.hours)
        @motion.reload.should be_waitingsecond
      end

      it "updates the motion state to 'closed' after 48 if it doesn't get enough seconds" do
        ScheduledMotionUpdate.perform(@motion.id, 'waitingsecond', 48.hours)
        @motion.reload.should be_closed
      end
    end

    context "for a motion waiting for seconds that has been marked as expedited" do
      before do
        @motion = Factory(:motion, :expedited => true)
      end

      it "doesn't update the motion state before 48 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'waitingsecond', 47.hours)
        @motion.reload.should be_waitingsecond
      end

      it "updates the motion state to 'discussing' after 48 if it can be discussed" do
        2.times { Factory(:second, :motion_id => @motion.id) }
        ScheduledMotionUpdate.perform(@motion.id, 'waitingsecond', 48.hours)
        @motion.reload.should be_discussing
      end

      it "updates the motion state to 'closed' after 48 if it can't be discussed" do
        ScheduledMotionUpdate.perform(@motion.id, 'waitingsecond', 48.hours)
        @motion.reload.should be_closed
      end
    end

    context "for a motion being discussed that hasn't been objected" do
      before do
        @motion = Factory(:discussing_motion)
      end

      it "doesn't update the motion state before 24 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'discussing', 23.hours)
        @motion.reload.should be_discussing
      end

      it "updates the motion state to 'voting' after 24 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'discussing', 24.hours)
        @motion.reload.should be_voting
      end
    end

    context "for a motion being discussed that has been objected" do
      before do
        @motion = Factory(:discussing_motion)
        Factory(:membership).member.object(@motion)
      end

      it "doesn't update the motion state before 48 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'discussing', 47.hours)
        @motion.reload.should be_discussing
      end

      it "updates the motion state to 'voting' after 48 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'discussing', 48.hours)
        @motion.reload.should be_voting
      end
    end

    context "for a motion being voted" do
      before do
        @motion = Factory(:voting_motion)
      end

      it "doesn't update the motion state before 48 hours" do
        ScheduledMotionUpdate.perform(@motion.id, 'voting', 47.hours)
        @motion.reload.should be_voting
      end

      it "updates the motion state to 'closed' after 48" do
        ScheduledMotionUpdate.perform(@motion.id, 'voting', 48.hours)
        @motion.reload.should be_closed
      end
    end
  end
end
