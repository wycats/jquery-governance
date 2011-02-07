class MotionEventsController < ApplicationController

  before_filter :authenticate_member!, :except => [:show]

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
