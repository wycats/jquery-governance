class MotionSearchesController < ApplicationController
  def new
  end

  def results
    @results = Motion.tsearch(params[:search][:keywords])
  end
end
