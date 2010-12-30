# Provides two services to ease the task of updating a {Motion motion} state in
# a given period of time.
#
# It's a Resque job which will try to update the motion state and provides a
# helper to create and enqueue the job.
class ScheduledMotionUpdate
  @queue = :scheduled_motion_update

  # This will be called by a worker when a job needs to be processed.  It will
  # try to find the motion in the given state and update its state, by calling
  # {MotionState::Base#scheduled_update}.
  # @param [Fixnum] motion_id The ID of the motion to be updated.
  # @param [string] motion_state_name The state name of the motion to be updated.
  # @param [Fixnum] time_elapsed The time elapsed since the motion has entered the current state.
  def self.perform(motion_id, motion_state_name, time_elapsed)
    motion = Motion.find_by_id_and_state_name(motion_id, motion_state_name)
    motion.scheduled_update(time_elapsed) unless motion.nil?
  end

  # Helper to create and enqueue this Resque job, whose processing will be
  # delayed the given amount of time.
  # @param [Fixnum] time The amount of time to be waited before processing the job.
  # @param [Motion] motion The motion that needs to update its state in a given amount of time.
  def self.in(time, motion)
    Resque.enqueue_at(time.from_now, self, motion.id, motion.state_name, time)
  end
end
