require 'spec_helper'

describe Motion do
  before(:each) do
    Resque.redis.flushall
  end

  describe "#voting!" do
    it "enqueues a Motions::Voting job" do
      motion = Factory(:motion)

      motion.voting!

      Resque.delayed_queue_schedule_size.should == 1
    end

    it "fails after 48 hours if not enough for pass" do
      motion = Factory(:motion)

      motion.voting!

      Resque.size("voting").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      Resque.size("voting").should == 1

      @worker.process
      motion.reload.should be_failed
    end

    it "does nothing if vote passed prior to 48 hours" do
      motion = Factory(:motion)

      motion.voting!
      motion.passed!

      Resque.size("voting").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      Resque.size("voting").should == 1

      @worker.process
      motion.reload.should be_passed
    end
  end
end
