module MotionsHelper
  def html_classes_for_motion_list_item(motion, last=false)
    classes = []
    classes << 'acted_on' if member? && current_member.has_acted_on?(motion)
    classes << 'last' if last
    classes.join(' ')
  end

  def motion_status_badge(motion)
    status = if motion.waitingsecond? && motion.expedited?
      'expedited'
    elsif motion.passed?
      'passed'
    elsif motion.approved?
      'approved'
    elsif motion.failed?
      'failed'
    end

    badge(status, :class => "status #{status}") unless status.blank?
  end
end
