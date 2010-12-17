class Admin::BaseController < ApplicationController
  before_filter :authenticate_member!
  before_filter :admin_required

  respond_to :html


  private

  def admin_required
    current_member.is_admin?
  end
end
