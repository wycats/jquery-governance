class ConflictsController < ApplicationController
  def index
    render :json => Conflict.all.map(&:name)
  end
end
