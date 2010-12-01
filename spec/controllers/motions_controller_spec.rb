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
end
