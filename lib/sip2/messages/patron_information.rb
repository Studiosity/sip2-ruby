# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Patron information message
    #
    # https://developers.exlibrisgroup.com/wp-content/uploads/2020/01/3M-Standard-Interchange-Protocol-Version-2.00.pdf
    #
    # Request message  63
    # Response message 64
    #
    class PatronInformation < Base
      private

      def build_message(uid:, password:, terminal_password: nil)
        code = '63' # Patron information
        language = '000' # Unknown
        timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
        summary = ' ' * 10
        [
          code, language, timestamp, summary,
          'AO|AA', uid, '|AC', terminal_password, '|AD', password
        ].join
      end

      def handle_response(response)
        Sip2::PatronInformation.new response if response =~ /\A64/
      end
    end
  end
end
