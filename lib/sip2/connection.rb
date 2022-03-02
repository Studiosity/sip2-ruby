module Sip2
  #
  # Sip2 Connection
  #
  class Connection
    @connection_modules = []

    class << self
      attr_reader :connection_modules

      def add_connection_module(module_name)
        @connection_modules << module_name
      end
    end

    include Messages::Login
    include Messages::PatronInformation
    include Messages::PatronStatus
    include Messages::SelfCheckoutStatus

    def initialize(socket, ignore_error_detection)
      @socket = socket
      @ignore_error_detection = ignore_error_detection
      @sequence = 1
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
      send "handle_#{message_type}_response", response
    end

    def send_message(message)
      @socket.send(message + "\r", 0)
      @socket.gets "\r"
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
      format '%4.4X', check
    end

    def sequence_and_checksum_valid?(response)
      return true if @ignore_error_detection
      sequence_regex = /^(?<message>.*?AY(?<sequence>[0-9]+)AZ)(?<checksum>[A-F0-9]{4})$/
      match = response.strip.match sequence_regex
      match &&
        match[:sequence] == @sequence.to_s &&
        match[:checksum] == checksum_for(match[:message])
    ensure
      @sequence += 1
    end
  end
end
