class SessionsController < ApplicationController
  if Rails.env.cucumber?
    def backdoor
      logout_killing_session!
      @current_member = Member.find_by_email(params[:email])
      head :ok
    end
  end
end
