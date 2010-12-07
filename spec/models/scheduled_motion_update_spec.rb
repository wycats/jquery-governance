require 'spec_helper'

describe ScheduledMotionUpdate do
  before(:all) do
    @motion = Factory(:motion)
  end

  describe ".perform" do
    it "finds the motion" do
      @motion.stub(:scheduled_update)
      Motion.should_receive(:find_by_id_and_state_name).with(@motion.id, @motion.state_name).and_return(@motion)
      ScheduledMotionUpdate.perform(@motion.id, @motion.state_name, 24.hours)
    end

    it "sends the message 'scheduled_update' to the motion" do
      Motion.stub(:find_by_id_and_state_name => @motion)
      @motion.should_receive(:scheduled_update).with(24.hours)
      ScheduledMotionUpdate.perform(@motion.id, @motion.state_name, 24.hours)
    end
  end
end
