require 'spec_helper'

describe Admin::BaseController do

  describe "#index with admin logged in" do
    before(:each) do
      @admin = Factory(:active_admin_membership).member
      controller.stub!(:authenticate_member!).and_return true
      controller.stub!(:current_member).and_return @admin
      controller.stub!(:admin_required).and_return true
    end

    it "should rendere the admin index template" do
      get :index
      response.should render_template('admin/base/index')
    end
  end

end
