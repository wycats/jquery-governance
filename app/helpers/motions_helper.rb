module MotionsHelper
  def html_attrs_for_motion(motion)
    classes = [dom_class(motion), state_class_for_motion(motion)]
    classes << 'seconded' if member? && current_member.seconded_motions.open_state.include?(motion)
    {
      :id    => dom_id(motion),
      :class => classes.compact.join(' ')
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
      content_tag(
        :div,
        link_to('More', show_more_motions_path, :class => 'more_motions quick-tool', :'data-last-id' => motions.last.id),
        :class => 'more_motions'
      )
    end
  end
end
