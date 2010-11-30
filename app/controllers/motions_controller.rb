class MotionsController < ApplicationController
  
  before_filter :authenticate_member!

  def new
    @motion = Motion.new(:member_id => current_member.id)
  end
end
