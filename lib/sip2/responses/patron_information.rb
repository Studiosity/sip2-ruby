module Sip2
  module Responses
    #
    # Sip2 Patron Information
    #
    class PatronInformation < BaseResponse
      register_response_code 64

      def patron_valid?
        boolean 'BL'
      end

      def authenticated?
        boolean 'CQ'
      end

      def email
        text 'BE'
      end

      def location
        text 'AQ'
      end

      private

      def attributes_for_inspect
        %i[patron_valid? authenticated? email location]
      end
    end
  end
end
