class WelcomeController < ApplicationController
  def index
    @motions = Motion.limit(10).order("created_at DESC")
  end
end
