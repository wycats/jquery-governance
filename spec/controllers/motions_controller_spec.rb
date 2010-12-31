require 'spec_helper'

describe MotionsController do

  describe "#new with member logged in" do
    before(:all) do
      @member = Factory(:member)
    end

    before(:each) do
      sign_in @member
    end

    it "should set memeber id" do
      get :new
      assigns(:motion).member_id.should_not be_nil
    end

    it "should render the new motion tempate" do
      get :new
      response.should render_template(:new)
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

    it "should render the index template with motions" do
      get :index
      response.should render_template(:index)
      assigns(:motions).should_not be_nil
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

    it "should render the index template with motion groups" do
      get :closed
      response.should render_template(:index)
      assigns(:motions).should_not be_nil
    end
  end
end
