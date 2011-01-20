class MotionSeconding
  def self.do(member, motion)
    event = Event.create(:member => member, :motion => motion, :event_type => 'second')
    update_motion_state(motion) if event.persisted?
    event.persisted?
  end

  private

  def self.update_motion_state(motion)
    if motion.expedited?
      motion.voting! if motion.can_expedite?
    else
      motion.discussing! if motion.can_wait_objection?
    end
  end
end
