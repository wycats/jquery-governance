module JqueryVoting
  class FormBuilder < ActionView::Helpers::FormBuilder
    def error_msg(field)
      error_msg = object.errors[field].to_sentence

      unless error_msg.empty?
        @template.send :content_tag, :p, error_msg, :class => 'error_msg'
      end
    end

    def approved_motions_select(method)
      collection = Motion.closed.find_all { |motion| motion.approved? }
      @template.send :collection_select, @object_name, method, collection, :id, :title, :prompt => true
    end
  end
end
