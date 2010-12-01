class MotionsController < ApplicationController
  
  before_filter :authenticate_member!

  def new
    @motion = Motion.new(:member_id => current_member.id)
  end

  def create
    @motion = Motion.new(params[:motion])
    @motion.member = current_member

    if @motion.save
      flash[:notice] = "New motion was created successfully"
      redirect_to root_url
    else
      render :new
    end
  end
end
