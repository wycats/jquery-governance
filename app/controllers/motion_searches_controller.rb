class MotionSearchesController < ApplicationController
  def new
  end

  def results
    motion_search = MotionSearch.new(current_member)

    unless @motions = motion_search.find(params[:search][:keywords])
      redirect_to new_motion_search_url, :alert => 'No results found'
    end
  end
end
