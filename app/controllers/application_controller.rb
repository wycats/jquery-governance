class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :member?, :admin?, :active_member?

  def member?
    current_member
  end

  def admin?
    active_member? && current_member.is_admin?
  end

  def active_member?
    current_member && current_member.membership_active?
  end

  def require_active_member
    if active_member?
      true
    else
      flash[:notice] = "You are not authorized to view this page."
      redirect_to root_url
    end
  end
end
