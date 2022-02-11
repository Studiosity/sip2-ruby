module Sip2
  module Messages
    #
    # Sip2 Patron Status message module
    #
    # https://developers.exlibrisgroup.com/alma/integrations/selfcheck/sip2
    #
    # Self Checkout status (99)
    # Output message: 9909992.00
    #
    module SelfCheckoutStatus
      def self.included(klass)
        klass.add_connection_module :self_checkout_status
      end

      private

      def build_self_checkout_status_message
        code = '99' # Self Checkout status
        status_code = '0' # SC unit is okay
        max_print_width = '999' # Terminal width (required, but we don't care)
        protocol_version = '2.00' # SIP2 version

        code + status_code + max_print_width + protocol_version
      end

      def handle_self_checkout_status_response(response)
        return unless sequence_and_checksum_valid?(response)
        Sip2::Responses::SelfCheckoutStatus.new response
      end
    end
  end
end
