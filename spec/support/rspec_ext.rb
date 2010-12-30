# JD and YK (but mostly YK :) ): Rails master has changed the way that layouts
# are passed to the renderer.  Instead of strings they are now passed as arrays
# so that view can also render the layouts of their parents.  Rspec hasn't been
# updated yet it seems so this patch will get us through until its updated. 

module RSpec
  module Rails
    module ViewRendering
      PathSetDelegatorResolver.class_eval do
        def find_all(path, prefix, *args)
          path_set.find_all(path, [prefix],*args).collect do |template|
            ::ActionView::Template.new(
              "",
              template.identifier,
              template.handler,
              {
                :virtual_path => template.virtual_path,
                :format => template.formats
              }
            )
          end
        end
      end
    end
  end
end

