# frozen_string_literal: true

module Sip2
  #
  # Sip2 Client
  #
  class Client
    def initialize(host:, port:, ignore_error_detection: false, timeout: nil, ssl_context: nil)
      @host = host
      @port = port
      @ignore_error_detection = ignore_error_detection
      @timeout = timeout || NonBlockingSocket::DEFAULT_TIMEOUT
      @ssl_context = ssl_context
    end

    def connect # rubocop:disable Metrics/MethodLength
      socket = NonBlockingSocket.connect host: @host, port: @port, timeout: @timeout

      # If we've been provided with an SSL context then use it to wrap out existing connection
      if @ssl_context
        socket = ::OpenSSL::SSL::SSLSocket.new socket, @ssl_context
        socket.hostname = @host # Needed for SNI
        socket.sync_close = true
        socket.connect
        socket.post_connection_check @host # Validate the peer certificate matches the host
      end

      if block_given?
        yield Connection.new(socket: socket, ignore_error_detection: @ignore_error_detection)
      end
    ensure
      socket&.close
    end
  end
end
