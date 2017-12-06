module Sip2
  module Messages
    #
    # Sip2 Patron Status message module
    #
    # https://developers.exlibrisgroup.com/alma/integrations/selfcheck/sip2
    #
    # Patron status (23)
    #    language	 	            The language code
    #                           Should match the "self-check" profile in Alma
    #    transactionDate	 	    Current date
    #    institutionId	    AO	The institution ID
    #                           E.g. 01MY_INST
    #    patronIdentifier 	AA	Any identifier that is defined in Alma as "unique cross institution"
    #    terminalPassword	  AC  As defined on the relevant circulation desk in Alma
    #    patronPassword	    AD	This is the "PIN number" of the patron
    #                           Should be sent only if "Authentication Required" is
    #                           set to "Y" on the self-check protocol in Alma
    #
    module PatronStatus
      def self.included(klass)
        klass.add_connection_module :patron_status
      end

      private

      def build_patron_status_message(uid, password)
        code = '23' # Patron status
        language = '000' # Unknown
        timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
        parts = [code, language, timestamp, 'AO|AA', uid, '|AC']
        parts += ['|AD', password] if password.is_a?(String)
        parts.join
      end

      def handle_patron_status_response(response)
        return unless sequence_and_checksum_valid?(response)
        Sip2::Responses::PatronStatus.new response
      end
    end
  end
end
