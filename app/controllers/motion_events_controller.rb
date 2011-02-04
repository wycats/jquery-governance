class MotionEventsController < ApplicationController

  before_filter :authenticate_member!, :except => [:show]

  # Show an Event for a given Motion
  # @option params [Fixnum] :motion_id The id of the motion in question
  # @option params [String] :event_id The id of the event to be viewed
  def show
    @motion = Motion.find(params[:motion_id])
    @event  = @motion.events.where :event_id => params[:event_id]
  end

  def create
    @motion = Motion.find(params[:motion_id])
    @event  = current_member.events.new(params[:event].merge(:motion => @motion))

    if @event.save
      flash[:notice] = t("events.notices.#{@event.event_type}")
      redirect_to motion_url(@motion)
    else
      # TODO
    end
  end
end
