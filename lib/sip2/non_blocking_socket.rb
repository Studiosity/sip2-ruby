require 'socket'
require 'timeout'

module Sip2
  #
  # Sip2 Non-blocking socket
  # From https://spin.atomicobject.com/2013/09/30/socket-connection-timeout-ruby/
  #
  class NonBlockingSocket < Socket
    DEFAULT_TIMEOUT = 5
    SEPARATOR = "\r".freeze

    def send_with_timeout(message, separator = SEPARATOR)
      ::Timeout::timeout (connection_timeout || DEFAULT_TIMEOUT), WriteTimeout do
        send message + separator, 0
      end
    end

    def gets_with_timeout(separator = SEPARATOR)
      ::Timeout::timeout (connection_timeout || DEFAULT_TIMEOUT), ReadTimeout do
        gets separator
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.connect(host, port, timeout = DEFAULT_TIMEOUT)
      # Convert the passed host into structures the non-blocking calls can deal with
      addr = Socket.getaddrinfo(host, nil)
      sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])

      NonBlockingSocket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0).tap do |socket|
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        socket.connection_timeout = timeout

        begin
          # Initiate the socket connection in the background. If it doesn't fail
          # immediately it will raise an IO::WaitWritable (Errno::EINPROGRESS)
          # indicating the connection is in progress.
          socket.connect_nonblock(sockaddr)
        rescue IO::WaitWritable
          # IO.select will block until the socket is writable or the timeout
          # is exceeded - whichever comes first.
          if IO.select(nil, [socket], nil, timeout)
            begin
              # Verify there is now a good connection
              socket.connect_nonblock(sockaddr)
            rescue Errno::EISCONN # rubocop:disable Lint/HandleExceptions
              # Good news everybody, the socket is connected!
            rescue StandardError
              # An unexpected exception was raised - the connection is no good.
              socket.close
              raise
            end
          else
            # IO.select returns nil when the socket is not ready before timeout
            # seconds have elapsed
            socket.close
            raise ConnectionTimeout
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    attr_accessor :connection_timeout
  end
end
