class MotionEventsController < ApplicationController

  before_filter :authenticate_member!, :except => [:index, :show]

  # Display events for a given Motion
  # @option params [Fixnum] :motion_id The id of the motion in question
  def index
    @motion     = Motion.find(params[:motion_id])
    @events     = @motion.events if @motion.present?
    @actionable = member_signed_in? and @motion.open?
    @tags       = Tag.selectable(params[:motion_id])
  end

  # Show an Event for a given Motion
  # @option params [Fixnum] :motion_id The id of the motion in question
  # @option params [String] :event_id The id of the event to be viewed
  def show
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.events.where :event_id => params[:event_id]
  end

  # Create a Seconding Event for a Motion
  # @option params [Fixnum] :motion_id The id of the motion in question
  def second
    @motion = Motion.find(params[:motion_id])
    if current_member.second(@motion)
      flash[:notice] = "You have successfully seconded the motion."
    else
      flash[:alert] =  "Something went wrong when seconding the motion"
    end

    redirect_to motion_events_url(@motion)
  end

  # Create an Objection Event for a Motion
  # @option params [Fixnum] :motion_id The id of the motion in question
  def object
    @motion = Motion.find(params[:motion_id])

    if @motion.object(current_member)
      flash[:notice] = "You have successfully objected the motion."
    else
      flash[:alert] =  "Something went wrong when objecting the motion"
    end

    redirect_to motion_events_url(@motion)
  end
  # Create a Voting Event for a Motion
  # @option params [Fixnum] :motion_id The id of the motion in question
  # @option params [Fixnum] :vote The vote cast by the member, can be "aye" or "nay"
  def vote
    @motion = Motion.find(params[:motion_id])

    if current_member.vote(@motion, params[:vote] == "aye")
      flash[:notice] = "You have successfully voted the motion."
    else
      flash[:alert] =  "Something went wrong when voting the motion"
    end

    redirect_to motion_events_url(@motion)
  end
end
