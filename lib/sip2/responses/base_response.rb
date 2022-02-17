module Sip2
  module Responses
    # Base class for response parsers.  Provides helpers for getting
    # text and boolean fields from the response.
    #
    class BaseResponse
      class EmptyResponseException < StandardError
      end
      attr_reader :raw_response

      # rubocop:disable Style/ClassVars
      @@response_objects = {}

      def initialize(raw_response)
        @raw_response = raw_response&.strip
        return unless @raw_response.nil? || @raw_response.empty?

        raise EmptyResponseException, 'raw_response from SIP2 server cannot be blank'
      end

      # Look up the proepr response class for the given response
      # based on the response code.
      def self.response_class_for_raw_response(raw_response)
        code = raw_response[0..1]
        @@response_objects[code] || BaseResponse
      end

      # Override `inspect` to output a more helpful, human readable string
      #
      def inspect
        attribute_parts = attributes_for_inspect.map do |attribute|
          "@#{attribute}=#{send(attribute).inspect}"
        end
        format_string = "#<%s:0x%p #{attribute_parts.join(' ')}>"
        format(
          format_string,
          self.class.name,
          object_id
        )
      end

      private

      # Retrieve a text string from the response.
      def text(message_id, length = nil)
        if message_id.is_a?(Numeric)
          parse_positional_text(raw_response, message_id, length)
        else
          parse_text(raw_response, message_id)
        end
      end

      # Retrieve an integer value of known length from the response.
      def numeric(position, length)
        raw_response[position + 2, length].to_i
      end

      # Retrieve a boolean value from the response.
      def boolean(message_id)
        if message_id.is_a?(Numeric)
          parse_positional_argument(raw_response, message_id)
        else
          parse_boolean(raw_response, message_id)
        end
      end

      # Parse a boolean response.  If message is not found, return nil
      # so we can tell it apart from a "N" (false) answer
      #
      def parse_boolean(response, message_id)
        msg = response[/\|#{message_id}([YN])\|/, 1]
        return true if msg == 'Y'
        return false if msg == 'N'
        false
      end

      def parse_text(response, message_id)
        response[/\|?#{message_id}(.*?)\|/, 1]
      end

      def parse_positional_text(response, position, length)
        response[position + 2, length]
      end

      def parse_positional_argument(response, position)
        response[position + 2] == 'Y'
      end

      def attributes_for_inspect
        []
      end

      class << self
        private

        def register_response_code(code)
          @@response_objects[code] = self
        end
      end
    end
  end
end
