# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Patron information message
    #
    # https://developers.exlibrisgroup.com/wp-content/uploads/2020/01/3M-Standard-Interchange-Protocol-Version-2.00.pdf
    #
    # Request message 63
    #  * language               - 3 char, fixed-length required field
    #  * transaction date       - 18 char, fixed-length required field: YYYYMMDDZZZZHHMMSS
    #  * summary                - 10 char, fixed-length required field
    #  * institution id    - AO - variable-length required field
    #  * patron identifier - AA - variable-length required field
    #  * terminal password - AC - variable-length optional field
    #  * patron password   - AD - variable-length optional field
    #  * start item        - BP - variable-length optional field
    #  * end item          - BQ - variable-length optional field
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
        return if response !~ /\A#{Sip2::Responses::PatronInformation::RESPONSE_ID}/

        Sip2::Responses::PatronInformation.new response
      end
    end
  end
end
