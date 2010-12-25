module ApplicationHelper
  # Will grab the name of the motion's creator and handle any exceptions that arise.
  # @todo: This shouldn't really exist, but I don't want pages to blowed up while testing
  # @param [Motion] motion The motion in question
  # @return [String] The name of the motion's creator or "Member" if invalid
  def motion_creator_display_name(motion)
    begin
      motion.member.name
    rescue NoMethodError
      Rails.logger.warn "Creator of Motion (#{motion.inspect}) either does not exist or does not have a name assigned"
      "Member"
    end
  end

  def positive_button_to(name, options = {}, html_options = {})
    append_html_classes(html_options, 'button', 'possitive')
    button_to(name, options, html_options)
  end

  def negative_button_to(name, options = {}, html_options = {})
    append_html_classes(html_options, 'button', 'negative')
    button_to(name, options, html_options)
  end

  def badge(text, html_options={})
    append_html_class(html_options, 'badge')
    content_tag(:span, html_options) { text }
  end

  def append_html_classes(html_options, *classes)
    html_options[:class] = [html_options[:class], *classes].compact.join(' ')
  end
  alias :append_html_class :append_html_classes
end
