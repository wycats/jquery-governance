module ApplicationHelper
  def positive_button_to(name, options = {}, html_options = {})
    append_html_classes(html_options, 'button', 'positive')
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
