class MotionsController < ApplicationController

  before_filter :authenticate_member!, :except => [:index, :show_more]

  # List Motions that are open (NOT passed, failed, approved)
  def index
    @motions = Motion.order('created_at DESC').limit(6)
  end

  # List Motions that are closed (passed, failed, approved)
  def closed
    @motions = Motion.closed_state.order('created_at DESC').limit(6)
  end

  # Start a new Motion
  def new
    @motion = current_member.motions.build
  end

  # Show more records for the motion state section
  def show_more
    @motions = Motion.prev_with_same_state(params[:id]).order('created_at DESC').limit(6)
  end

  # Create a new Event
  #   @option params [Hash] :motion The new motion to create
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
