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
end
