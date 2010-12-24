class MotionsController < ApplicationController

  before_filter :authenticate_member!, :except => [:index, :show_more]

  # List Motions that are open (NOT passed, failed, approved)
  def index
    scope = Motion.paginate

    if active_member?
      @motion_groups      = Motion.active_member_groups(scope)
      @motion_groups_name = :open
    else
      @motion_groups      = Motion.public_groups(scope)
      @motion_groups_name = :public
    end
  end

  # List Motions that are closed (passed, failed, approved)
  def closed
    @motions = Motion.closed_state.paginate
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
      redirect_to root_url
    else
      render :new
    end
  end
end
