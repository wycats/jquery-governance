class WelcomeController < ApplicationController
  def index
    @motions = Motion.all
  end
end
