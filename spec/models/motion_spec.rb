require 'spec_helper'

describe Motion do
  before do
    RSpec::Mocks::setup(self)

    @motion = Factory.create(:motion)
  end

  describe "validations" do
    before do
      @motion = Motion.new(
        :title => 'Budget for Printed Programs',
        :description => 'This vote is to set a max budget of $1500 for...',
        :member_id => 1
      )
    end

    it "is valid with valid attributes" do
      @motion.should be_valid
    end

    it "is not valid without a title" do
      @motion.title = nil
      @motion.should_not be_valid
    end

    it "is not valid without a description" do
      @motion.description = nil
      @motion.should_not be_valid
    end

    it "is not valid without a member" do
      @motion.member_id = nil
      @motion.should_not be_valid
    end

    it "is not valid with an inexistent state name" do
      @motion.state_name = 'inexistent'
      @motion.should_not be_valid
    end
  end

  context "a newly created motion" do
    it "is in the waitingsecond state" do
      @motion.should be_waitingsecond
    end

    it "notifies members of that a new motion has been created" do
      @motion = Factory.build(:motion)
      ActiveMemberNotifier.should_receive(:deliver).with(:motion_created, @motion)
      @motion.save
    end

    it "schedules an update in 48 hours" do
      @motion = Factory.build(:motion)
      ScheduledMotionUpdate.should_receive(:in).with(48.hours, @motion)
      @motion.save
    end
  end

  describe "discussing!" do
    it "turns the motion into the discussing state" do
      @motion.discussing!
      @motion.should be_discussing
    end

    it "notifies members of that discussion of the motion has begun" do
      ActiveMemberNotifier.should_receive(:deliver).with(:discussion_beginning, @motion)
      @motion.discussing!
    end


    it "schedules updates in 24 and 48 hours" do
      ScheduledMotionUpdate.should_receive(:in).with(24.hours, @motion)
      ScheduledMotionUpdate.should_receive(:in).with(48.hours, @motion)
      @motion.discussing!
    end
  end

  describe "voting!" do
    it "turns the motion into the voting state" do
      @motion.voting!
      @motion.should be_voting
    end

    it "notifies members of that voting on the motion has begun" do
      ActiveMemberNotifier.should_receive(:deliver).with(:voting_beginning, @motion)
      @motion.voting!
    end

    it "schedules an update in 48 hours" do
      ScheduledMotionUpdate.should_receive(:in).with(48.hours, @motion)
      @motion.voting!
    end
  end

  describe "closed!" do
    it "turns the motion into the closed state" do
      @motion.closed!
      @motion.should be_closed
    end

    it "sets the time when the motion was closed" do
      @motion.closed_at.should be_nil
      @motion.closed!
      @motion.closed_at.should_not be_nil
    end

    it "notifies members of the outcome of the motion now that it is closed" do
      ActiveMemberNotifier.should_receive(:deliver).with(:motion_closed, @motion)
      @motion.closed!
    end
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

  # describe 'conflicts_with?', :database => true do
  #   before :each do
  #     @member   = Factory.build(:membership).member
  #     @conflict = Factory.build(:conflict)
  #   end

  #   describe "when a member has a conflict unrelated to this motion" do
  #     it "knows that it doesn't conflict with the member" do
  #       @member.conflicts << @conflict
  #       @motion.should_not be_conflicts_with(@member)
  #     end
  #   end

  #   describe "when a motion has conflict unrelated to this member" do
  #     it "knows that it doesn't conflict with the member" do
  #       @motion.conflicts << @conflict
  #       @member.conflicts.clear
  #       @motion.should_not be_conflicts_with(@member)
  #     end
  #   end

  #   describe "when a motion and a member share the same conflict" do
  #     it "knows that it conflicts with the member" do
  #       @motion.conflicts << @conflict
  #       @member.conflicts << @conflict
  #       @motion.should be_conflicts_with(@member)
  #     end
  #   end
  # end

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
    it "knows the available state names" do
      Motion.states.should include('waitingsecond')
      Motion.states.should include('discussing')
      Motion.states.should include('voting')
      Motion.states.should include('closed')

      Motion.states.size.should == 4
    end

    it "knows the public state names" do
      Motion.states(:public).should include('voting')
      Motion.states(:public).should include('closed')

      Motion.states(:public).size.should == 2
    end

    it "knows the open state names" do
      Motion.states(:open).should include('waitingsecond')
      Motion.states(:open).should include('discussing')
      Motion.states(:open).should include('voting')

      Motion.states(:open).size.should == 3
    end

    it "knows the closed state names" do
      Motion.states(:closed).should == %w(closed)
    end
  end
end

describe Motion, "waitingsecond" do
  before(:all) do
    @active_member = Factory(:membership).member
    @inactive_member = Factory(:expired_membership).member
    @motion = Factory(:motion)
  end

  describe "permit?" do
    it "allows an active member to see the motion" do
      @motion.permit?(:see, @active_member).should be_true
    end

    it "doesn't allow an inactive member to see the motion" do
      @motion.permit?(:see, @inactive_member).should be_false
    end

    it "doesn't allow an active member to object the motion" do
      @motion.permit?(:object, @active_member).should be_false
    end

    it "doesn't allow an inactive member to object the motion" do
      @motion.permit?(:object, @inactive_member).should be_false
    end

    it "doesn't allow an active member to vote the motion" do
      @motion.permit?(:vote, @active_member).should be_false
    end

    it "doesn't allow an inactive member to vote the motion" do
      @motion.permit?(:vote, @inactive_member).should be_false
    end

    it "allows an active member to second another member's motion" do
      @motion.permit?(:second, @active_member).should be_true
    end

    it "doesn't allow an active member to second more than once another member's motion" do
      @active_member.second(@motion)
      @motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an active member to second its own motion" do
      @owned_motion = Factory(:motion, :member => @active_member)
      @owned_motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an inactive member to second the motion" do
      @motion.permit?(:second, @inactive_member).should be_false
    end
  end
end

describe Motion, "discussing" do
  before(:all) do
    @active_member = Factory(:membership).member
    @inactive_member = Factory(:expired_membership).member
    @motion = Factory(:discussing_motion)
  end

  describe "permit?" do
    it "allows an active member to see the motion" do
      @motion.permit?(:see, @active_member).should be_true
    end

    it "doesn't allow an inactive member to see the motion" do
      @motion.permit?(:see, @inactive_member).should be_false
    end

    it "allows an active member to object the motion" do
      @motion.permit?(:object, @active_member).should be_true
    end

    it "doesn't allow a member to object the motion more than once" do
      @active_member.object(@motion)
      @motion.permit?(:object, @active_member).should be_false
    end

    it "doesn't allow an inactive member to object the motion" do
      @motion.permit?(:object, @inactive_member).should be_false
    end

    it "doesn't allow an active member to vote the motion" do
      @motion.permit?(:vote, @active_member).should be_false
    end

    it "doesn't allow an inactive member to vote the motion" do
      @motion.permit?(:vote, @inactive_member).should be_false
    end

    it "doesn't allow an active member to second another member's motion" do
      @motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an active member to second its own motion" do
      @owned_motion = Factory(:discussing_motion, :member => @active_member)
      @owned_motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an inactive member to second the motion" do
      @motion.permit?(:second, @inactive_member).should be_false
    end
  end
end

describe Motion, "voting" do
  before(:all) do
    @active_member = Factory(:membership).member
    @inactive_member = Factory(:expired_membership).member
    @motion = Factory(:voting_motion)
  end

  describe "permit?" do
    it "allows an active member to see the motion" do
      @motion.permit?(:see, @active_member).should be_true
    end

    it "allows an inactive member to see the motion" do
      @motion.permit?(:see, @inactive_member).should be_true
    end

    it "doesn't allow an active member to object the motion" do
      @motion.permit?(:object, @active_member).should be_false
    end

    it "doesn't allow an inactive member to object the motion" do
      @motion.permit?(:object, @inactive_member).should be_false
    end

    it "allows an active member to vote the motion" do
      @motion.permit?(:vote, @active_member).should be_true
    end

    it "doesn't allow an active member to vote the motion more than once" do
      @motion.stub(:vote).and_return(Factory(:yes_vote, :motion => @motion, :member => @active_member))
      @motion.vote(@active_member, true)
      @motion.permit?(:vote, @active_member).should be_false
    end

    it "doesn't allow an active member to vote the motion if there's a conflict of interest" do
      @motion.stub(:conflicts_with?).with(@active_member).and_return(true)
      @motion.permit?(:vote, @active_member).should be_false
    end

    it "doesn't allow an inactive member to vote the motion" do
      @motion.permit?(:vote, @inactive_member).should be_false
    end

    it "doesn't allow an active member to second another member's motion" do
      @motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an active member to second its own motion" do
      @owned_motion = Factory(:voting_motion, :member => @active_member)
      @owned_motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an inactive member to second the motion" do
      @motion.permit?(:second, @inactive_member).should be_false
    end
  end
end

describe Motion, "closed" do
  before(:all) do
    @active_member = Factory(:membership).member
    @inactive_member = Factory(:expired_membership).member
    @motion = Factory(:closed_motion)
  end

  describe "permit?" do
    it "allows an active member to see the motion" do
      @motion.permit?(:see, @active_member).should be_true
    end

    it "allows an inactive member to see the motion" do
      @motion.permit?(:see, @inactive_member).should be_true
    end

    it "doesn't allow an active member to object the motion" do
      @motion.permit?(:object, @active_member).should be_false
    end

    it "doesn't allow an inactive member to object the motion" do
      @motion.permit?(:object, @inactive_member).should be_false
    end

    it "doesn't allow an active member to vote the motion" do
      @motion.permit?(:vote, @active_member).should be_false
    end

    it "doesn't allow an inactive member to vote the motion" do
      @motion.permit?(:vote, @inactive_member).should be_false
    end

    it "doesn't allows an active member to second another member's motion" do
      @motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an active member to second its own motion" do
      @owned_motion = Factory(:closed_motion, :member => @active_member)
      @owned_motion.permit?(:second, @active_member).should be_false
    end

    it "doesn't allow an inactive member to second the motion" do
      @motion.permit?(:second, @inactive_member).should be_false
    end
  end
end
