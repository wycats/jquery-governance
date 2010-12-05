require 'spec_helper'

describe Motion do
  before do
    @motion = Factory(:motion)
  end

  before(:each) do
    Resque.redis.flushall
  end

  describe "#voting!" do
    it "enqueues a motions::Voting job" do

      @motion.voting!

      Resque.delayed_queue_schedule_size.should == 1
    end

    it "fails after 48 hours if not enough for pass" do

      @motion.voting!

      # Resque.size("voting").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      # Resque.size("voting").should == 1

      @worker.process
      @motion.reload.should be_failed
    end

    it "does nothing if vote passed prior to 48 hours" do

      @motion.voting!
      @motion.passed!

      # Resque.size("voting").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      # Resque.size("voting").should == 1

      @worker.process
      @motion.reload.should be_passed
    end
  end
end
