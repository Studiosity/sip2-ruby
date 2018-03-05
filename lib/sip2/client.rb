module Sip2
  #
  # Sip2 Client
  #
  class Client
    def initialize(host:, port:, ignore_error_detection: false)
      @host = host
      @port = port
      @ignore_error_detection = ignore_error_detection
    end

    def connect
      socket = NonBlockingSocket.connect @host, @port
      yield Connection.new(socket, @ignore_error_detection) if block_given?
    ensure
      socket.close if socket
    end
  end
end
