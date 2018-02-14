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
        '#<%<class_name>s:0x%<object_id>p @patron_valid="%<patron_valid>s"' \
        ' @email="%<email>s" @authenticated="%<authenticated>s">',
        class_name: self.class.name,
        object_id: object_id,
        patron_valid: patron_valid?,
        email: email,
        authenticated: authenticated?
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
