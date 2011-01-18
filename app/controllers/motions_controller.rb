class MotionsController < ApplicationController

  before_filter :authenticate_member!, :except => [:index, :show_more]

  # List Motions that are open (NOT passed, failed, approved)
  def index
    @group = MotionSorter.group_for(current_member, :name => active_member? ? :open : :public)
  end

  # List Motions that are closed (passed, failed, approved)
  def closed
    @group = MotionSorter.group_for(current_member, :name => :closed)
    render :index
  end

  # Start a new Motion
  def new
    @motion = current_member.motions.build
  end

  # Show more records for the motion state section
  def show_more
    @motions = Motion.prev_with_same_state(params[:id]).paginate
  end

  # Create a new Event
  def create
    @motion = current_member.motions.build(params[:motion])

    if @motion.save
      flash[:notice] = "New motion was created successfully"
      redirect_to motion_events_url(@motion)
    else
      render :new
    end
  end
end
