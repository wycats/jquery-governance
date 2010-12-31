class MotionSearchesController < ApplicationController
  def new
  end

  def results
    # Here are the search results
    results = Motion.search(params[:search][:keywords])

    # Scope them so that user's can't see motions they lack
    # the permissons to view
    @motions = Motion.motion_groups_for_user(current_member, results)
  end
end
