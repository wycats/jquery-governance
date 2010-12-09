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

  def render_motion_list(motions, &block)
    if motions.empty?
      haml_concat(capture_haml(&block))
    else
      haml_tag(:ul) do
        motions.each do |motion|
          haml_concat(render(:partial => 'motions/list_item', :locals => { :motion => motion }))
        end
      end
    end
    haml_concat(link_to_more_motions(motions))
  end

  def link_to_more_motions(motions)
    if motions.count > motions.size
      render(:partial => 'motions/link_to_more', :locals => { :state => motions.last.state_name, :last_id => motions.last.id })
    end
  end
end
