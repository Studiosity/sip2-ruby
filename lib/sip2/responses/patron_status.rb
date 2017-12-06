module Sip2
  module Responses
    #
    # Sip2 Patron Status Response
    #
    # Patron status response (24)
    #
    #   patronStatus	 	          Supported values:
    #
    #                             0 - Charge privileges (N if the user is blocked,
    #                                 not active or expired)
    #                             3 - Hold privileges (N if the user is blocked,
    #                                 not active or expired)
    #                             5 - Too many items
    #                             6 - Too many items overdue
    #                             10,11 - Outstanding fine/fees
    #    language	 	              The language code
    #                   	        Ad defined on the "self-check" profile in Alma
    #    transactionDate	  	    Current date
    #    institutionId	      AO	The institution ID
    #                             E.g. 01MY_INST
    #    patronIdentifier	    AA	the patron id as received in the "patron status" message
    #    personalName	        AE	Patron's First Middle and Last Name
    #    validPatron	        BL	Y/N indication if the received patron id is valid
    #    validPatronPassword	CQ	Y/N indication if the received patron password is valid
    #    currencyType	        BH	Institution currency
    #    feeAmount	          BV	Patron's active balance
    #
    # Sample response:
    # 24              00020101014    120240|BHGBP|BLY|CQY|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD
    #
    class PatronStatus < BaseResponse
      register_response_code 24

      def charge_privileges_denied?
        boolean 0
      end

      def renewal_privileges_denied?
        boolean 1
      end

      def excessive_fines_or_fees?
        boolean(10) || boolean(11)
      end

      def fee_amount
        text 'BV'
      end

      def personal_name
        text 'AE'
      end

      def valid_patron?
        boolean 'BL'
      end

      def valid_patron_password?
        boolean 'CQ'
      end

      private

      def attributes_for_inspect
        %i[fee_amount personal_name valid_patron? valid_patron_password? 
           excessive_fines_or_fees? charge_privileges_denied? 
           renewal_privileges_denied?]
      end
    end
  end
end
