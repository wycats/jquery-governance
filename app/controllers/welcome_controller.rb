class WelcomeController < ApplicationController
  def index
    @motions = Motion.open_state.paginate :page => params[:page], :order => "state, created_at DESC", :per_page => 10
  end
end
