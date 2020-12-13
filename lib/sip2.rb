# frozen_string_literal: true

require 'sip2/version'

require 'openssl'

require 'sip2/responses/base'
require 'sip2/responses/patron_information'
require 'sip2/responses/status'

require 'sip2/messages/base'
require 'sip2/messages/login'
require 'sip2/messages/patron_information'
require 'sip2/messages/status'

module Sip2
  class TimeoutError < StandardError; end

  class ConnectionTimeout < TimeoutError; end

  class WriteTimeout < TimeoutError; end

  class ReadTimeout < TimeoutError; end
end

require 'sip2/non_blocking_socket'
require 'sip2/connection'
require 'sip2/client'
