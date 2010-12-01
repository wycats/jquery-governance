class MotionConflict < ActiveRecord::Base
  belongs_to :conflict
  belongs_to :motion
end
