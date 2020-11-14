# frozen_string_literal: true

module Sip2
  #
  # Sip2 Connection
  #
  class Connection
    LINE_SEPARATOR = "\r"

    @connection_modules = []

    class << self
      attr_reader :connection_modules

      def add_connection_module(module_name)
        @connection_modules << module_name
      end
    end

    include Messages::Login
    include Messages::PatronInformation

    def initialize(socket, ignore_error_detection)
      @socket = socket
      @ignore_error_detection = ignore_error_detection
      @sequence = 1
    end

    def send_message(message)
      puts_with_timeout message
      gets_with_timeout
    end

    def method_missing(method_name, *args)
      if Connection.connection_modules.include?(method_name.to_sym)
        send_and_handle_message(method_name, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      Connection.connection_modules.include?(method_name.to_sym) || super
    end

    private

    def send_and_handle_message(message_type, *args)
      message = send "build_#{message_type}_message", *args
      message = with_checksum with_error_detection message
      response = send_message message
      return if response.nil?

      send "handle_#{message_type}_response", response
    end

    def puts_with_timeout(message, separator: LINE_SEPARATOR)
      ::Timeout.timeout connection_timeout, WriteTimeout do
        @socket.write message + separator
      end
    end

    def gets_with_timeout(separator: LINE_SEPARATOR)
      ::Timeout.timeout connection_timeout, ReadTimeout do
        @socket.gets(separator)&.chomp(separator)
      end
    end

    def connection_timeout
      # We want the underlying connection where the timeout is configured,
      # so if we're dealing with an SSLSocket then we need to unwrap it
      io = @socket.respond_to?(:io) ? @socket.io : @socket
      io.connection_timeout || NonBlockingSocket::DEFAULT_TIMEOUT
    end

    def with_error_detection(message)
      message + '|AY' + @sequence.to_s
    end

    def with_checksum(message)
      message += 'AZ'
      message + checksum_for(message)
    end

    def checksum_for(message)
      check = 0
      message.each_char { |m| check += m.ord }
      check += "\0".ord
      check = (check ^ 0xFFFF) + 1
      format '%<check>4.4X', check: check
    end

    def sequence_and_checksum_valid?(response)
      return true if @ignore_error_detection

      sequence_regex = /\A(?<message>.*?AY(?<sequence>[0-9]+)AZ)(?<checksum>[A-F0-9]{4})\z/
      match = response.strip.match sequence_regex
      match &&
        match[:sequence] == @sequence.to_s &&
        match[:checksum] == checksum_for(match[:message])
    ensure
      @sequence += 1
    end
  end
end
