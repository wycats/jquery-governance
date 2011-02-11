class MotionSearchesController < ApplicationController
  def new
  end

  def results
    @group = MotionGroup.search(params[:search][:keywords], current_member)

    if @group.empty?
      redirect_to new_motion_search_url, :alert => 'No results found'
    end
  end
end
