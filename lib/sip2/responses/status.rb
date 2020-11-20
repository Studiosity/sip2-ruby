# frozen_string_literal: true

module Sip2
  module Responses
    #
    # Sip2 Patron Information
    #
    # https://developers.exlibrisgroup.com/wp-content/uploads/2020/01/3M-Standard-Interchange-Protocol-Version-2.00.pdf
    #
    # Response message 98
    #  * on-line status          - 1 char, fixed-length required field: Y or N
    #  * checkin ok              - 1 char, fixed-length required field: Y or N
    #  * checkout ok             - 1 char, fixed-length required field: Y or N
    #  * ACS renewal policy      - 1 char, fixed-length required field: Y or N
    #  * status update ok        - 1 char, fixed-length required field: Y or N
    #  * off-line ok             - 1 char, fixed-length required field: Y or N
    #  * timeout period          - 3 char, fixed-length required field
    #  * retries allowed         - 3 char, fixed-length required field
    #  * date / time sync        - 18 char, fixed-length required field: YYYYMMDDZZZZHHMMSS
    #  * protocol version        - 4 char, fixed-length required field: x.xx
    #  * institution ID     - AO - variable-length required field
    #  * library name       - AM - variable-length optional field
    #  * supported messages - BX - variable-length required field
    #  * terminal location  - AN - variable-length optional field
    #  * screen message     - AF - variable-length optional field
    #  * print line         - AG - variable-length optional field
    #
    class Status < Base
      RESPONSE_ID = 98
      SUPPORTED_MESSAGES = {
        patron_status_request: 0,
        checkout: 1,
        checkin: 2,
        block_patron: 3,
        status: 4,
        request_resend: 5,
        login: 6,
        patron_information: 7,
        end_patron_session: 8,
        fee_paid: 9,
        item_information: 10,
        item_status_update: 11,
        patron_enable: 12,
        hold: 13,
        renew: 14,
        renew_all: 15
      }.freeze

      def online?
        parse_fixed_boolean 0
      end

      def checkin_ok?
        parse_fixed_boolean 1
      end

      def checkout_ok?
        parse_fixed_boolean 2
      end

      def acs_renewal_policy?
        parse_fixed_boolean 3
      end

      def status_update_ok?
        parse_fixed_boolean 4
      end

      def offline_ok?
        parse_fixed_boolean 5
      end

      def timeout_period
        parse_fixed_response 6, 3
      end

      def retries_allowed
        parse_fixed_response 9, 3
      end

      def date_sync
        parse_datetime 12
      end

      def protocol_version
        parse_fixed_response 30, 4
      end

      def institution_id
        parse_text 'AO'
      end

      def library_name
        parse_text 'AM'
      end

      def supported_messages
        message = parse_text('BX').to_s

        SUPPORTED_MESSAGES.each_with_object([]) do |(supported_message, index), acc|
          acc << supported_message if message[index] == 'Y'
        end
      end

      def terminal_location
        parse_text 'AN'
      end

      def screen_message
        parse_text 'AF'
      end

      def print_line
        parse_text 'AG'
      end

      def inspect
        format(
          '#<%<class_name>s:0x%<object_id>p @online="%<online>s"' \
          ' @protocol_version="%<protocol_version>s"',
          class_name: self.class.name,
          object_id: object_id,
          online: online?,
          protocol_version: protocol_version
        )
      end
    end
  end
end
