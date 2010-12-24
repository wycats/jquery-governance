class MotionsController < ApplicationController

  before_filter :authenticate_member!, :except => [:index, :show_more]

  # List Motions that are open (NOT passed, failed, approved)
  def index
    scope = Motion.paginate
    @motion_groups = if active_member?
                      Motion.active_member_groups(scope)
                    else
                      Motion.public_groups(scope)
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
