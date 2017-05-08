module Sip2
  #
  # Sip2 Patron Information
  #
  class PatronInformation
    attr_reader :raw_response

    def initialize(patron_response)
      @raw_response = patron_response
    end

    def patron_valid?
      raw_response[/\|BL([YN])\|/, 1] == 'Y'
    end

    def authenticated?
      raw_response[/\|CQ([YN])\|/, 1] == 'Y'
    end

    def email
      raw_response[/\|BE(.*?)\|/, 1]
    end

    def inspect
      format(
        '#<%s:0x%p @patron_valid="%s" @email="%s" @authenticated="%s">',
        self.class.name,
        object_id,
        patron_valid?,
        email,
        authenticated?
      )
    end
  end
end
