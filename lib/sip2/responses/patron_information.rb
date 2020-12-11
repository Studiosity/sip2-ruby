# frozen_string_literal: true

module Sip2
  module Responses
    #
    # Sip2 Patron Information
    #
    # https://developers.exlibrisgroup.com/wp-content/uploads/2020/01/3M-Standard-Interchange-Protocol-Version-2.00.pdf
    #
    # Response message 64
    #  * patron status                - 14 char, fixed-length required field
    #  * language                     - 3 char, fixed-length required field
    #  * transaction date             - 18 char, fixed-length required field: YYYYMMDDZZZZHHMMSS
    #  * hold items count             - 4 char, fixed-length required field
    #  * overdue items count          - 4 char, fixed-length required field
    #  * charged items count          - 4 char, fixed-length required field
    #  * fine items count             - 4 char, fixed-length required field
    #  * recall items count           - 4 char, fixed-length required field
    #  * unavailable holds count      - 4 char, fixed-length required field
    #  * institution id          - AO - variable-length required field
    #  * patron identifier       - AA - variable-length required field
    #  * personal name           - AE - variable-length required field
    #  * hold items limit        - BZ - 4 char, fixed-length optional field
    #  * overdue items limit     - CA - 4 char, fixed-length optional field
    #  * charged items limit     - CB - 4 char, fixed-length optional field
    #  * valid patron            - BL - 1 char, optional field: Y or N
    #  * valid patron password   - CQ - 1 char, optional field: Y or N
    #  * currency type           - BH - 3 char, fixed-length optional field
    #  * fee amount              - BV - variable-length optional field
    #  * fee limit               - CC - variable-length optional field
    #  * hold items              - AS - variable-length optional field
    #  * overdue items           - AT - variable-length optional field
    #  * charged items           - AU - variable-length optional field
    #  * fine items              - AV - variable-length optional field
    #  * recall items            - BU - variable-length optional field
    #  * unavailable hold items  - CD - variable-length optional field
    #  * home address            - BD - variable-length optional field
    #  * email address           - BE - variable-length optional field
    #  * home phone number       - BF - variable-length optional field
    #  * screen message          - AF - variable-length optional field
    #  * print line              - AG - variable-length optional field
    #
    class PatronInformation < Base
      RESPONSE_ID = 64
      FIXED_LENGTH_CHARS = 61 # 59 chars + 2 for the header

      def charge_privileges_denied?
        parse_fixed_boolean 0
      end

      def renewal_privileges_denied?
        parse_fixed_boolean 1
      end

      def recall_privileges_denied?
        parse_fixed_boolean 2
      end

      def hold_privileges_denied?
        parse_fixed_boolean 3
      end

      def card_reported_lost?
        parse_fixed_boolean 4
      end

      def too_many_items_charged?
        parse_fixed_boolean 5
      end

      def too_many_items_overdue?
        parse_fixed_boolean 6
      end

      def too_many_renewals?
        parse_fixed_boolean 7
      end

      def too_many_claims_of_items_returned?
        parse_fixed_boolean 8
      end

      def too_many_items_lost?
        parse_fixed_boolean 9
      end

      def excessive_outstanding_fines?
        parse_fixed_boolean 10
      end

      def excessive_outstanding_fees?
        parse_fixed_boolean 11
      end

      def recall_overdue?
        parse_fixed_boolean 12
      end

      def too_many_items_billed?
        parse_fixed_boolean 13
      end

      def language
        LANGUAGE_LOOKUP_TABLE[parse_fixed_response(14, 3)]
      end

      def transaction_date
        parse_datetime 17
      end

      def patron_valid?
        parse_optional_boolean 'BL'
      end

      def authenticated?
        parse_optional_boolean 'CQ'
      end

      def email
        parse_text 'BE'
      end

      def location
        parse_text 'AQ'
      end

      def screen_message
        parse_text 'AF'
      end

      def inspect
        format(
          '#<%<class_name>s:0x%<object_id>p @patron_valid="%<patron_valid>s"' \
          ' @email="%<email>s" @authenticated="%<authenticated>s">',
          class_name: self.class.name,
          object_id: object_id,
          patron_valid: patron_valid?,
          email: email,
          authenticated: authenticated?
        )
      end
    end
  end
end
