class Notifications < ActionMailer::Base
  default :from => "notifications@jquery.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.motion_created.subject
  #
  def motion_created(motion, member)
    @motion = motion
    @member = member

    subject_text = "#{I18n.t("notifications.motion_created.subject")}: #{motion.title}"

    mail :to      => member.email,
         :subject => subject_text
  end

  # Notifies a member via e-mail when a motion's state changes
  # @param [Symbol] to_state The state change being performed
  # @param [Motion] motion The motion being changed
  # @param [Member] member The member receiving the e-mail notification
  # @return [Mail::Message] The generated e-mail object
  def motion_state_changed(motion, member)
    @motion = motion
    @member = member

    subject_text = I18n.t("notifications.motion_state_changed.subjects.#{motion.state_name}") + ": #{motion.title}"

    mail :to      => member.email,
         :subject => subject_text
  end
end
