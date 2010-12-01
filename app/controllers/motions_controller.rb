class MotionsController < ApplicationController
  
  before_filter :authenticate_member!

  def index
    @motions = Motion.all
  end
  
  def new
    @motion = Motion.new(:member_id => current_member.id)
  end
end
