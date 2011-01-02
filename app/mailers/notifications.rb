class Notifications < ActionMailer::Base
  default :from => "notifications@jquery.org"

  helper :notifications

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.motion_created.subject
  #
  def motion_created(motion, member)
    construct_message(:motion_created, motion, member)
  end

  def discussion_beginning(motion, member)
    construct_message(:discussion_beginning, motion, member)
  end

  def voting_beginning(motion, member)
    construct_message(:voting_beginning, motion, member)
  end

  def motion_closed(motion, member)
    construct_message(:motion_closed, motion, member)
  end

  private

  def construct_message(name, motion, member)
    @motion = motion
    @member = member

    subject_text = "#{motion.title} #{I18n.t("notifications.#{name}.subject")}"

    mail :to      => member.email,
         :subject => subject_text

    @template = name

  end
end
