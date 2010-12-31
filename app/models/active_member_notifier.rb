# This class is a Resque job to send email notifications to the active members.
# Also it provides a helper to create and enqueue it.
class ActiveMemberNotifier
  @queue = :active_member_notifier

  # This will be called by a worker when a job needs to be processed.  It will
  # send the given notification to all the current active members.
  # @param [String, Symbol] notification The message that will be sended to {Notifications}.
  # @param [Fixnum] motion_id The id of the motion that triggered the notification.
  def self.perform(notification, motion_id)
    motion = Motion.find(motion_id)
    Membership.members_active_at(Time.now).each do |member|
      Notifications.send(notification, motion, member).deliver
    end
  end

  # Helper to create and enqueue this Resque job.
  # @param [String, Symbol] notification The message that will be sended to {Notifications}.
  # @param [Motion] motion_id The motion that triggered the notification.
  def self.deliver(notification, motion)
    Resque.enqueue(self, notification, motion.id)
  end
end
