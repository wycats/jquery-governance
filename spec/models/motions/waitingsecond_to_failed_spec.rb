require 'spec_helper'


# SHOULD NOT HAVE TO DO THIS
require File.dirname(__FILE__) + "/../../factories.rb"

describe Motion do

  before do
    Resque.redis.flushall
  end

  context "moving to the waitingsecond state" do
    it "enqueues a Motions::WaitingsecondToFailed job" do
      motion = Factory(:motion)

      motion.waitingsecond!

      Resque.delayed_queue_schedule_size.should == 1
    end
  end

  context "in the waitingsecond state post 48 hours" do
    it "moves the motion to failed state" do
      motion = Factory(:motion)
      
      motion.waitingsecond!

      Resque.size("waitingsecond_to_failed").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      Resque.size("waitingsecond_to_failed").should == 1

      worker = Resque::Worker.new(:waitingsecond_to_failed)
      worker.work(0)

      motion.reload.should be_failed
    end
  end
end
