# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Patron information message
    #
    # https://developers.exlibrisgroup.com/wp-content/uploads/2020/01/3M-Standard-Interchange-Protocol-Version-2.00.pdf
    #
    # Request message 99
    #  * status code      - 1 char, fixed-length required field: 0, 1 or 2
    #  * max print width  - 3 char, fixed-length required field
    #  * protocol version - 4 char, fixed-length required field: x.xx
    #
    class Status < Base
      STATUS_CODE_LOOKUP = {
        ok: 0,
        out_of_paper: 1,
        about_to_shut_down: 2
      }.freeze

      private

      def build_message(status_code: :ok, max_print_width: 999, protocol_version: 2)
        [
          '99', # SC Status
          normalize_status_code(status_code),
          normalize_print_width(max_print_width),
          normalize_protocol_version(protocol_version)
        ].join
      end

      def normalize_status_code(code)
        format(
          '%<code>d',
          code: (code.is_a?(Symbol) ? STATUS_CODE_LOOKUP[code] : code).to_i.abs
        )[0]
      end

      def normalize_print_width(width)
        format('%03<width>d', width: width % 1000)
      end

      def normalize_protocol_version(version)
        format('%.2<version>f', version: version % 10)
      end

      def handle_response(response)
        return unless /\A#{Sip2::Responses::Status::RESPONSE_ID}/o.match?(response)

        Sip2::Responses::Status.new response
      end
    end
  end
end
