module TagsHelper
  def highlight_new_tag(current_tag)
    @new_tag_id.to_i == current_tag.id ? 'highlight_fade' : ''
  end

  def tag_badge(tag)
    badge(tag.name, :class => 'tag')
  end
end
