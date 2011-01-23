module JqueryVoting
  class FormBuilder < ActionView::Helpers::FormBuilder
    def error_msg(field)
      error_msg = object.errors[field].to_sentence

      unless error_msg.empty?
        @template.send :content_tag, :p, error_msg, :class => 'error_msg'
      end
    end
  end
end
