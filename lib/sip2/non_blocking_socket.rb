# frozen_string_literal: true

require 'socket'
require 'timeout'

module Sip2
  #
  # Sip2 Non-blocking socket
  # From https://spin.atomicobject.com/2013/09/30/socket-connection-timeout-ruby/
  #
  class NonBlockingSocket < Socket
    DEFAULT_TIMEOUT = 5

    attr_accessor :connection_timeout

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.connect(host:, port:, timeout: DEFAULT_TIMEOUT)
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
          # wait_writable waits until the socket is writable without blocking,
          # and returns self or `nil` when times out
          if socket.wait_writable(timeout)
            begin
              # Verify there is now a good connection
              socket.connect_nonblock(sockaddr)
            rescue Errno::EISCONN
              # Good news everybody, the socket is connected!
            rescue StandardError
              # An unexpected exception was raised - the connection is no good.
              socket.close
              raise
            end
          else
            # wait_writable returns nil when the socket is not ready before timeout
            # seconds have elapsed
            socket.close
            raise ConnectionTimeout
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
