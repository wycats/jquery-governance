# YK: Rack defines #escape to use a Unicode regular expression. It's not clear
# to me why they do this, and CGI.escape (where this code was taken from) does
# not use a unicode regular expression. This change means that BINARY strings
# cannot be escaped.
#
# Since the percent encoding spec allows percent-encoding binary data, using
# a unicode regular expression here seems incorrect.

module Rack
  module Utils
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
    module_function :escape
  end
end
