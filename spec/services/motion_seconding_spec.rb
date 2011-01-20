require 'spec_helper'

describe MotionSeconding do
  before do
    @motion = mock_model('Motion', :expedited? => false, :can_expedite? => false, :can_wait_objection? => false)
    @member = mock_model('Member')
    @event  = mock_model('Event')
    Event.stub(:create => @event)
  end

  describe ".do" do
    it "tries to create a second with the given member and motion" do
      Event.should_receive(:create).with(:motion => @motion, :member => @member, :event_type => 'second')
      MotionSeconding.do(@member, @motion)
    end

    context "when the second is created" do
      it "returns true" do
        MotionSeconding.do(@member, @motion).should be_true
      end

      context "when the motion is marked as expedited" do
        before do
          @motion.stub(:expedited? => true)
        end

        it "changes its state to voting if it has enough seconds" do
          @motion.stub(:can_expedite? => true)
          @motion.should_receive(:voting!)
          MotionSeconding.do(@member, @motion)
        end

        it "doesn't change its state to voting if it doesn't have enough seconds" do
          @motion.stub(:can_expedite? => false)
          @motion.should_not_receive(:voting!)
          MotionSeconding.do(@member, @motion)
        end
      end

      context "when the motion isn't marked as expedited" do
        before do
          @motion.stub(:expedited? => false)
        end

        it "changes its state to discussing if it has enough seconds" do
          @motion.stub(:can_wait_objection? => true)
          @motion.should_receive(:discussing!)
          MotionSeconding.do(@member, @motion)
        end

        it "doesn't change its state to voting if it doesn't have enough seconds" do
          @motion.stub(:can_wait_objection? => false)
          @motion.should_not_receive(:discussing!)
          MotionSeconding.do(@member, @motion)
        end
      end
    end

    context "when the second isn't created" do
      before do
        @event.stub(:persisted? => false)
      end

      it "returns false" do
        MotionSeconding.do(@member, @motion).should be_false
      end
    end
  end
end
