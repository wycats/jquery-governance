class MotionEventsController < ApplicationController

  before_filter :authenticate_member!, :except => [:index, :show]

  # Display events for a given Motion
  #   @option params [Fixnum] :motion_id The id of the motion in question
  def index
    @motion     = Motion.find(params[:motion_id])
    @events     = @motion.events if @motion.present?
    @actionable = member_signed_in? and @motion.open?
  end

  # Show an Event for a given Motion
  #   @option params [Fixnum] :motion_id The id of the motion in question
  #   @option params [String] :event_id The id of the event to be viewed
  def show
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.events.where :event_id => params[:event_id]
  end

  # Create a Seconding Event for a Motion
  #   @option params [Fixnum] :motion_id The id of the motion in question
  def second
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.seconds.new :value => true

    @event.member = current_member

    @disp   = "Successfully Seconded Motion" if @event.save
    @disp ||= "Error Seconding Motion"
  end

  # Create a Voting Event for a Motion
  #   @option params [Fixnum] :motion_id The id of the motion in question
  #   @option params [Fixnum] :vote The vote cast by the member, can be "aye" or "nay"
  def vote
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.votes.new :value  =>  case params[:vote]
                                            when "aye" then true
                                            when "nay" then false
                                            end

    @event.member = current_member

    @disp   = "Successful" if @event.save
    @disp ||= "Failed"
  end
end
