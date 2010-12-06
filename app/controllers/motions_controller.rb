class MotionsController < ApplicationController

  before_filter :authenticate_member!, :except => [:show, :index]

  # List Motions
  def index
    @motions = Motion.open_state.paginate :page => params[:page], :order => "state, created_at DESC", :per_page => 10
  end

  def closed
    @motions = Motion.closed_state.paginate :page => params[:page], :order => 'state, updated_at DESC', :per_page => 10
  end

  # Start a new Motion
  def new
    @motion = Motion.new(:member_id => current_member.id)
  end

  # This should not be used. Should take you to MotionEvents#index
  def show
    @motion = Motion.find(params[:id])
  end

  # Create a new Event
  #   @option params [Hash] :motion The new motion to create
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
