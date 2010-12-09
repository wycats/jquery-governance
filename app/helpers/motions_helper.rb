module MotionsHelper
  def html_attrs_for_motion(motion)
    {
      :id    => dom_id(motion),
      :class => "#{dom_class(motion)} #{state_class_for_motion(motion)}".strip
    }
  end

  def state_class_for_motion(motion)
    if motion.has_met_requirement?
      'passed'
    elsif motion.failed?
      'failed'
    end
  end
end
