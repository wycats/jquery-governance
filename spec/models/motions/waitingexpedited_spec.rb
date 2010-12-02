require 'spec_helper'

describe Motion do
  before(:each) do
    Resque.redis.flushall
  end

  describe "#waitingexpedited!" do
    it "enqueues a Motions::WaitingexpededToFailed and Motions::WaitingexpeditedToWaitingobjection job" do
      motion = Factory(:motion)

      motion.waitingexpedited!

      Resque.delayed_queue_schedule_size.should == 2
    end

    it "post 24 hours and with two seconds moves the motion to waitingobjection state" do
      motion = Factory.create(:motion)

      2.times do
        Factory.create(:second, :motion => motion)
      end

      motion.waitingexpedited!

      Resque.size("waitingexpedited_to_waitingobjection").should == 0
      Resque::Scheduler.handle_delayed_items(24.hours.from_now.to_i)
      Resque.size("waitingexpedited_to_waitingobjection").should == 1

      @worker.process
      motion.reload.should be_waitingobjection
    end

    it "post 48 hours moves the motion to failed state" do
      motion = Factory(:motion)

      motion.waitingexpedited!

      Resque.size("waitingexpedited_to_failed").should == 0
      Resque::Scheduler.handle_delayed_items(48.hours.from_now.to_i)
      Resque.size("waitingexpedited_to_failed").should == 1

      @worker.process
      motion.reload.should be_failed
    end
  end
end
