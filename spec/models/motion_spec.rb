require 'spec_helper'

describe Motion do
  before do
    @motion = Factory.create(:motion)
  end

  it "knows how many yea votes have been cast for the motion" do
    4.times { Factory.create(:yes_vote, :motion => @motion) }
    @motion.yeas.should == 4
  end

  it "knows how many nea votes have been cast for the motion" do
    3.times { Factory.create(:no_vote, :motion => @motion) }
    @motion.nays.should == 3
  end

  describe 'voting requirements' do
    before do
      #This reprsents all of the members who currently have the right to vote
      8.times { Factory.create(:active_membership) }
    end

    describe 'required_votes' do
      it "knows how many votes are required to pass the motion" do
         @motion.required_votes.should == 5
      end
    end

    describe 'has_met_requirement?' do

      describe "when there more than half of the possible votes are yeas" do
        before do
          5.times { Factory.create(:yes_vote, :motion => @motion) }
        end

        it "knows the requirment for passage has been met" do
           @motion.should be_has_met_requirement
        end
      end

      describe "when exactly half of the possible votes are yeas" do
        before do
          4.times{  Factory.create(:yes_vote, :motion => @motion)}
        end

        it "knows that the requirement for passage hasn't been met" do
           @motion.should_not be_has_met_requirement
        end
      end

      describe "when less than half the possible votes are yeas" do
        before do
          3.times{  Factory.create(:yes_vote, :motion => @motion)}
        end

        it "knows that the requirement for passage hasn't been met" do
           @motion.should_not be_has_met_requirement
        end
      end
    end

    describe 'seconds_for_expedition' do
      it "knows how many seconds are needed to expidite the measure" do
        @motion.seconds_for_expedition.should == 3
      end
    end

    describe 'second(member)' do
      before do
        @member = Factory.create(:member)
      end

      it "creates a new second for the member" do
        lambda do
          @motion.second(@member)
        end.should change { @motion.seconds.count }
      end

    end
  end
end
