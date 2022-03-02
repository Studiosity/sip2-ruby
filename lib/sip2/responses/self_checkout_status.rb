module Sip2
  module Responses
    #
    # Sip2 Patron Status Response
    #
    # Self checkout status response (98)
    #
    # 98YYYYNN99999920101014    1158092.00AOMAIN|BXYYYNYYYYNNNNNYYN|AY0AZEDE3
    #
    # Message Fixed-width Positional Attributes in order from left to right:
    # 
    # 98                    - the message identifier.
    # YYYYNN                - status flags for online_status, check_in_ok, check_out_ok, renewal_policy, status_update_ok, and offline_ok.
    # 999                   - timeout period
    # 999                   - number of retries allowed.
    # 20101014    115809    - the datetime offset.
    # 2.00                  - the SIP version targeted.
    #
    # Other fields are indexed by keys:
    #
    # institutionId      AO - the institution ID. e.g. MAIN
    #
    # supportedMessages |BX| In character position order:
    #   - Patron Status Request (23)
    #   - Checkout (11)
    #   - Checkin (09)
    #   - Block Patron (01)
    #   - SC/ACS Status (99)
    #   - Request SC/ACS Resend (97)
    #   - Login (93)
    #   - Patron Information (63)
    #   - End Patron Session (35)
    #   - Fee Paid (37)
    #   - Item Information (17)
    #   - Item Status Update (19)
    #   - Patron Enable (25)
    #   - Hold (15)
    #   - Renew (29)
    #   - Renew All (65)
    #
    class SelfCheckoutStatus < BaseResponse
      register_response_code 98

      def online_status?
        boolean 0
      end

      def check_in_ok?
        boolean 1
      end

      def check_out_ok?
        boolean 2
      end

      def renewal_policy?
        boolean 3
      end

      def status_update_ok?
        boolean 4
      end

      def offline_ok?
        boolean 5
      end

      def timeout_period
        numeric 6, 3
      end

      def retries_allowed
        numeric 9, 3
      end

      # This is not a properly formatted datetime.
      def date_time_sync
        text 12, 18
      end

      # Expected to be "2.00"
      def version
        text 30, 4
      end

      def institution_id
        text 'AO'
      end

      def library_name
        text 'AM'
      end

      # This could be parsed further to provide more customized SIP2 integrations
      def supported_messages
        text 'BX'
      end

      def screen_message
        text 'AF'
      end

      def print_line
        text 'AG'
      end

      private

      def attributes_for_inspect
        %i[fee_amount personal_name valid_patron? valid_patron_password? 
           excessive_fines_or_fees? charge_privileges_denied? 
           renewal_privileges_denied? screen_message]
      end
    end
  end
end
