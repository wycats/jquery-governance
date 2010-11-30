require 'spec_helper'

require File.dirname(__FILE__) + "/../../factories.rb"

describe Motion do
  before(:each) do
    Resque.redis.flushall
  end

  describe "#waitingobjection!" do
    it "enqueues a Motions::WaitingobjectionToVoting job" do
      motion = Factory(:motion)
    
      motion.waitingobjection!

      Resque.delayed_queue_schedule_size.should == 1
    end

    it "post 24 hours and still in waitingobjection moves motion to voting" do
      motion = Factory(:motion)
     
      motion.waitingobjection!
  
      Resque.size("waitingobjection_to_voting").should == 0
      Resque::Scheduler.handle_delayed_items(24.hours.from_now.to_i)
      Resque.size("waitingobjection_to_voting").should == 1

      @worker.process
      motion.reload.should be_voting
    end

    it "post 24 hours and in objected state enqueues Motions::ObjectedToVoting job" do
      motion = Factory(:motion)
     
      motion.waitingobjection!
      motion.objected!
  
      Resque.size("waitingobjection_to_voting").should == 0
      Resque::Scheduler.handle_delayed_items(24.hours.from_now.to_i)
      Resque.size("waitingobjection_to_voting").should == 1

      @worker.process
      motion.reload.should be_objected 

      Resque.delayed_queue_schedule_size.should == 1
    end
  end
end
