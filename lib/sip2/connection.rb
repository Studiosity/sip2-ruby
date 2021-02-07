# frozen_string_literal: true

module Sip2
  #
  # Sip2 Connection
  #
  class Connection
    LINE_SEPARATOR = "\r"

    def initialize(socket:, ignore_error_detection: false)
      @socket = socket
      @ignore_error_detection = ignore_error_detection
      @sequence = 1
    end

    def send_message(message)
      message = with_checksum with_error_detection message
      write_with_timeout message
      # Read the response and strip any leading newline
      # - Some ACS terminate messages with /r/n by mistake.
      #   We need to remove from the front (i.e. buffer remnant from the previous message)
      response = read_with_timeout&.[](/\A\n?(.*)\z/, 1)
      response if sequence_and_checksum_valid? response
    ensure
      @sequence += 1
    end

    def method_missing(method_name, *args)
      message_class = Messages::Base.message_class_for_method(method_name)
      if message_class.nil?
        super
      else
        message_class.new(self).action_message(*args)
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      !Messages::Base.message_class_for_method(method_name).nil? || super
    end

    private

    def write_with_timeout(message, separator: LINE_SEPARATOR)
      ::Timeout.timeout connection_timeout, WriteTimeout do
        @socket.write message + separator
      end
    end

    def read_with_timeout(separator: LINE_SEPARATOR)
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
      "#{message}|AY#{@sequence}"
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
      return false unless response.is_a? String

      sequence_regex = /\A(?<message>.*?AY(?<sequence>[0-9]+)AZ)(?<checksum>[A-F0-9]{4})\z/
      match = response.strip.match sequence_regex
      match &&
        match[:sequence] == @sequence.to_s &&
        match[:checksum] == checksum_for(match[:message])
    end
  end
end
