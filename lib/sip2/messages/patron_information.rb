# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Patron information message module
    #
    module PatronInformation
      def self.included(klass)
        klass.add_connection_module :patron_information
      end

      private

      def build_patron_information_message(uid, password, terminal_password = nil)
        code = '63' # Patron information
        language = '000' # Unknown
        timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
        summary = ' ' * 10
        [
          code, language, timestamp, summary,
          'AO|AA', uid, '|AC', terminal_password, '|AD', password
        ].join
      end

      def handle_patron_information_response(response)
        return unless sequence_and_checksum_valid?(response)

        Sip2::PatronInformation.new response
      end
    end
  end
end
