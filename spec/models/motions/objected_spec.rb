require 'spec_helper'

describe Motion do
  before(:each) do
    Resque.redis.flushall
  end

  describe "#waitingobjection! -> #objected!" do
    it "post 24 hours and in objected state enqueues Motions::ObjectedToVoting job" do
      pending # NOTE just for now
      motion = Factory(:motion)

      motion.waitingobjection!
      motion.objected!

      Resque.delayed_queue_schedule_size.should == 2

      Resque.size("waitingobjection_to_voting").should == 0
      Resque::Scheduler.handle_delayed_items(24.hours.from_now.to_i)
      Resque.size("waitingobjection_to_voting").should == 1

      @worker.process
      motion.reload.should be_objected

      Resque.delayed_queue_schedule_size.should == 2

      Resque.size("objected_to_voting").should == 0
      Resque::Scheduler.handle_delayed_items(24.hours.from_now.to_i)
      Resque.size("objected_to_voting").should == 1

      @worker.process
      motion.reload.should be_voting
    end
  end
end
