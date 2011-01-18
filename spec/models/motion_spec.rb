require 'spec_helper'

describe Motion do
  before do
    RSpec::Mocks::setup(self)

    @motion = Factory.create(:motion)
  end

  describe "vote counting", :database => true do
    it "knows how many yea votes have been cast for the motion" do
      2.times { Factory.create(:yes_vote, :motion => @motion) }
      @motion.yeas.should == 2
    end

    it "knows how many nea votes have been cast for the motion" do
      1.times { Factory.create(:no_vote, :motion => @motion) }
      @motion.nays.should == 1
    end
  end

  describe "state_name=" do
    it "updates the motion's state name" do
      @motion.state_name = 'waitingsecond'
      @motion.state_name.should == 'waitingsecond'
    end

    it "updates the motion's state" do
      # NOTE this isn't a good spec, but I don't expect it to live long
      @motion.state_name = 'voting'
      @motion.state.should be_instance_of MotionState::Voting
    end
  end

  describe 'voting requirements' do
    before do
      # This represents all of the members who currently have the right to vote
      membership_scope = double('active membership scope', :count => 4)
      Membership.stub!(:active_at).and_return( membership_scope )
    end

    describe 'required_votes' do
      it "knows how many votes are required to pass the motion" do
        @motion.required_votes.should == 3
      end
    end

    describe 'has_met_requirement?' do

      describe "when there more than half of the possible votes are yeas" do
        before do
          @motion.stub(:yeas => 3)
        end

        it "knows the requirment for passage has been met" do
          @motion.should be_has_met_requirement
        end
      end

      describe "when exactly half of the possible votes are yeas" do
        before do
          @motion.stub(:yeas => 2)
        end

        it "knows that the requirement for passage hasn't been met" do
          @motion.should_not be_has_met_requirement
        end
      end

      describe "when less than half the possible votes are yeas" do
        before do
          @motion.stub(:yeas => 1)
        end

        it "knows that the requirement for passage hasn't been met" do
          @motion.should_not be_has_met_requirement
        end
      end
    end

    describe 'seconds_for_expedition' do
      it "knows how many seconds are needed to expedite the measure" do
        @motion.seconds_for_expedition.should == 2
      end
    end
  end

  describe 'conflicts_with_member?', :database => true do
    before :each do
      @member   = Factory.build(:membership).member
      @conflict = Factory.build(:conflict)
    end

    describe "when a member has a conflict unrelated to this motion" do
      it "knows that it doesn't conflict with the member" do
        @member.conflicts << @conflict
        @motion.should_not be_conflicts_with_member(@member)
      end
    end

    describe "when a motion has conflict unrelated to this member" do
      it "knows that it doesn't conflict with the member" do
        @motion.conflicts << @conflict
        @member.conflicts.clear
        @motion.should_not be_conflicts_with_member(@member)
      end
    end

    describe "when a motion and a member share the same conflict" do
      it "knows that it conflicts with the member" do
        @motion.conflicts << @conflict
        @member.conflicts << @conflict
        @motion.should be_conflicts_with_member(@member)
      end
    end
  end

  describe 'schedule_updates' do
    describe "when a motion is created" do
      it "should ask the MotionState to schedule updates" do
        @motion = Factory.build(:motion)
        @motion.state.should_receive(:schedule_updates)
        @motion.save
      end
    end

    describe "when a motion is saved with a state change" do
      it "should ask the MotionState to schedule updates" do
        @motion = Factory.create(:motion)
        @motion.state_name = "discussing"
        @motion.state.should_receive(:schedule_updates)
        @motion.save
      end
    end
  end

  describe "tag_list=" do
    it "updates the motion tags" do
      @motion = Factory.build(:motion)
      @motion.tag_list = 'legal events'

      @motion.tags.size.should == 2
      @motion.tags.any? { |t| t.name == 'legal' }.should be_true
      @motion.tags.any? { |t| t.name == 'events' }.should be_true
    end

    it "instantiates but doesn't save unexistent tags" do
      @motion = Factory.build(:motion)
      @motion.tag_list = 'legal'

      @motion.tags.first.should be_a_new_record
    end

    it "doesn't instantiate existent tags" do
      Factory.create(:tag, :name => 'legal')

      @motion = Factory.build(:motion)
      @motion.tag_list = 'legal'

      @motion.tags.first.should_not be_a_new_record
    end

    it "saves the unexistent tags when the motion is saved" do
      @motion = Factory.build(:motion)
      @motion.tag_list = 'legal'

      @motion.save
      @motion.tags.first.should_not be_a_new_record
    end
  end

  describe ".states" do
    it "returns the state names" do
      Motion.states.should include(:waitingsecond)
      Motion.states.should include(:discussing)
      Motion.states.should include(:voting)
      Motion.states.should include(:closed)

      Motion.states.size.should == 4
    end
  end
end
