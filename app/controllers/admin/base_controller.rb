module Admin
  class BaseController < ::ApplicationController
    before_filter :authenticate_member!
    before_filter :admin_required

    respond_to :html

    def index
      # no point having a page with just 1 link - go ahead and redirect there
      flash[:notice] = flash[:notice] if flash[:notice]
      redirect_to admin_members_path
    end

    private

    def admin_required
      unless admin?
        flash[:notice] = "Can not access that area."
        redirect_to motions_path
      end
    end
  end
end
