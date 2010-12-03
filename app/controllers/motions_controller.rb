class MotionsController < ApplicationController

  before_filter :authenticate_member!

  def index
    @motions = Motion.paginate :page => params[:page],
      :order => 'created_at DESC',
      :conditions => "state NOT IN ('passed', 'failed', 'approved')"
  end
  
  def closed
    @motions = Motion.paginate :page => params[:page],
      :order => 'updated_at DESC',
      :conditions => "state IN ('passed', 'failed', 'approved')"
  end

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
