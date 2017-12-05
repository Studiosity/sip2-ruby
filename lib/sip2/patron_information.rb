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
      parse_boolean raw_response, 'BL'
    end

    def authenticated?
      parse_boolean raw_response, 'CQ'
    end

    def email
      parse_text raw_response, 'BE'
    end

    def location
      parse_text raw_response, 'AQ'
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

    private

    def parse_boolean(response, message_id)
      response[/\|#{message_id}([YN])\|/, 1] == 'Y'
    end

    def parse_text(response, message_id)
      response[/\|#{message_id}(.*?)\|/, 1]
    end
  end
end
