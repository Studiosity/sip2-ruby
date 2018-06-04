require 'sip2/version'

require 'sip2/patron_information'

require 'sip2/messages/login'
require 'sip2/messages/patron_information'

module Sip2
  class TimeoutError < StandardError; end
  class ConnectionTimeout < TimeoutError; end
  class WriteTimeout < TimeoutError; end
  class ReadTimeout < TimeoutError; end
end

require 'sip2/non_blocking_socket'
require 'sip2/connection'
require 'sip2/client'
