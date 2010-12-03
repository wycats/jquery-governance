require 'spec_helper'

describe MotionEventsController do

  describe "#new with member logged in" do
    before(:each) do
      @member = Factory(:member)
      controller.stub!(:authenticate_member!).and_return true
      controller.stub!(:current_member).and_return @member
      @motion = Factory(:motion)
    end

    it "should set memeber id and event_type on a new event" do
      get :new, {:motion_id => @motion.id, :member_id => @member.id, :event_type => "vote"}
      assigns(:motion).should           == @motion
      assigns(:event).should            be_a_new_record
      assigns(:event).member_id.should  == @member.id
      assigns(:event).event_type.should == "vote"
    end

    it "should render the new motion tempate" do
      get :new, {:motion_id => @motion.id, :member_id => @member.id, :event_type => "vote"}
      response.should render_template('motion_events/new')
      assigns(:event).should be_a_new_record
    end
  end # describe "#new with member logged in"
end
