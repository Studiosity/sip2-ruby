# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Base message handler
    #
    class Base
      @message_class_lookup = {}

      # Class helper to fetch the descendant "message" class based on a method name
      #
      # @param [String] method_name the underscore case name of the class to fetch
      # @return [Class] the message class fetched based on the method_name,
      #                 `nil` if no descendant was found
      # @example
      #   message_class_for_method('patron_information')
      #   => Sip2::Messages::PatronInformation
      def self.message_class_for_method(method_name) # rubocop:disable Metrics/MethodLength
        return @message_class_lookup[method_name] if @message_class_lookup.key? :method_name

        @message_class_lookup[method_name] =
          begin
            # classify the method name so we can fetch the message class of the same name
            class_name = method_name.to_s.capitalize.gsub(%r{(?:_|(/))([a-z\d]*)}i) do
              "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
            end
            message_class = Messages.const_get(class_name)
            message_class if message_class && message_class < self
          rescue NameError
            nil
          end
      end

      def initialize(connection)
        @connection = connection
      end

      # Action the message, passing the dynamic arguments to the specific message implementation
      #
      # @param [*various] args Arguments to pass to the specific message implementation
      # @return returns `nil` if there was no valid message returned.
      #         Otherwise value will depend on the specific message. See the `handle_response`
      #         method in those classes for more information
      def action_message(**args)
        message = build_message(**args)
        response = @connection.send_message message
        return if response.nil?

        handle_response(response)
      end

      private

      def build_message(**)
        raise NotImplementedError, "#{self.class} must implement `build_message` method"
      end

      def handle_response(_response)
        raise NotImplementedError, "#{self.class} must implement `handle_response` method"
      end
    end
  end
end
