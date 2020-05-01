# frozen_string_literal: true

module Sip2
  #
  # Sip2 Client
  #
  class Client
    def initialize(host:, port:, ignore_error_detection: false, timeout: nil)
      @host = host
      @port = port
      @ignore_error_detection = ignore_error_detection
      @timeout = timeout || NonBlockingSocket::DEFAULT_TIMEOUT
    end

    def connect
      socket = NonBlockingSocket.connect @host, @port, @timeout
      yield Connection.new(socket, @ignore_error_detection) if block_given?
    ensure
      socket&.close
    end
  end
end
