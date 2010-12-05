require 'spec_helper'

describe Motion do
  before(:each) do
    Resque.redis.flushall
  end

  describe "#waitingsecond!" do
    it "enqueues a Motions::WaitingsecondToFailed job" do
      motion = Factory(:motion)

      Resque.delayed_queue_schedule_size.should == 1
    end

    it "post 48 hours moves the motion to failed state" do
      motion = Factory(:motion)

      # Resque.size("waitingsecond_to_failed").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      # Resque.size("waitingsecond_to_failed").should == 1

      @worker.process
      motion.reload.should be_failed
    end
  end
end
