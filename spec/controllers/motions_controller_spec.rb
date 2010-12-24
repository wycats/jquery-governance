require 'spec_helper'

describe MotionsController do

  describe "#new with member logged in" do
    before(:each) do
      @member = Factory(:member)
      controller.stub!(:authenticate_member!).and_return true
      controller.stub!(:current_member).and_return @member
    end

    it "should set memeber id" do
      get :new, :member_id => @member.id
      assigns(:motion).member_id.should_not be_nil
    end

    it "should render the new motion tempate" do
      get :new
      response.should render_template('motions/new')
      assigns(:motion).should be_a_new_record
    end
  end

  describe "#new with member logged out" do
    it "should redirect to login path" do
      get :new
      response.should redirect_to(new_member_session_path)
    end
  end

  describe "#index with member logged in" do
    before(:each) do
      11.times { Factory.create(:motion) }
      @member = Factory(:member)
      controller.stub!(:authenticate_member!).and_return true
      controller.stub!(:current_member).and_return @member
    end

    it "should render the index template with motion groups" do
      get :index
      response.should render_template('motions/index')
      assigns(:motion_groups).should_not be_nil
    end
    it "should render 1 more motion when the user clicks more"
  end

  describe "#closed with member logged in" do
    before(:each) do
      @motion = Factory.create(:motion)
      @motion.closed!
      @member = Factory(:member)
      controller.stub!(:authenticate_member!).and_return true
      controller.stub!(:current_member).and_return @member
    end

    it "should render the page page with 1 motion" do
      get :closed
      response.should render_template('motions/closed')
      assigns(:motions).count.should == 1
    end
  end
end
