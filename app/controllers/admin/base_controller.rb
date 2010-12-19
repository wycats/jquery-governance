class Admin::BaseController < ApplicationController
  before_filter :authenticate_member!
  before_filter :admin_required

  respond_to :html


  private

  def admin_required
    unless current_member.is_admin?
      flash[:notice] = "Can not access that area."
      redirect_to motions_path
    end
  end
end
