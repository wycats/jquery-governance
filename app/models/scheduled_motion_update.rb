class ScheduledMotionUpdate
  @queue = :scheduled_motion_update

  def self.perform(motion_id, motion_state_name, time_elapsed)
    motion = Motion.find_by_id_and_state_name(motion_id, motion_state_name)
    motion.scheduled_update(time_elapsed) unless motion.nil?
  end
end
