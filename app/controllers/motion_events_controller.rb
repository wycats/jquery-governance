class MotionEventsController < ApplicationController

  before_filter :authenticate_member!

  # Display events for a given Motion
  #   @option params [Fixnum] :motion_id The id of the motion in question
  def index
    @motion = Motion.find(params[:motion_id])
    @events = @motion.events unless @motion.empty?
  end

  # Show an Event for a given Motion
  #   @option params [Fixnum] :motion_id The id of the motion in question
  #   @option params [String] :event_id The id of the event to be viewed
  def show
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.events.where :event_id => params[:event_id]
  end

  # Start a new Event; event type must be supplied
  #   @option params [Fixnum] :motion_id The id of the motion in question
  #   @option params [String] :event_type The type of event to be created
  def new
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.events.new  :event_type => params[:event_type], 
                                  :member_id  => current_member.id
  end

  # Create a new Event
  #   @option params [Fixnum] :motion_id The id of the motion in question
  #   @option params [String] :event_type The type of event to be created
  #   @option params [Hash]   :event The new event to create
  def create
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.events.new  :event => params[:event]

    @event.member = current_member

    if @event.save
      flash[:notice] = "Your #{@event.event_type.capitalize} has been successfully cast."
      redirect_to @motion
    else
      # @TODO: Inform user
    end
  end
end
