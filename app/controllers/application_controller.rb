class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin?

  def require_admin
    unless admin?
      flash[:notice] = t("application.not_authorized")
      redirect_to motions_url
    else
      true
    end
  end

  def admin?
    current_member.try(:is_admin?)
  end
end
