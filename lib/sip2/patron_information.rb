module Sip2
  #
  # Sip2 Patron Information
  #
  class PatronInformation
    attr_reader :raw_response

    def initialize(patron_response)
      @raw_response = patron_response
    end

    def patron_status
      status = raw_response[/\A64(.{14})/, 1]
      status.strip if status
    end

    def language_code
      raw_response[/\A64.{14}(.{3})/, 1]
    end

    def transaction_date
      match = raw_response.match(/\A64.{17}(\d{4})(\d{2})(\d{2})(.{4})(\d{2})(\d{2})(\d{2})/)
      return unless match
      _, year, month, day, zone, hour, minute, second = match.to_a
      Time.new(
        year.to_i, month.to_i, day.to_i,
        hour.to_i, minute.to_i, second.to_i,
        offset_from_zone(zone)
      )
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

    def offset_from_zone(zone)
      zone.strip!
      lookup = TIME_ZONE_LOOKUP_TABLE.find { |_, v| v.include? zone }
      lookup ? lookup.first : '+00:00'
    end

    TIME_ZONE_LOOKUP_TABLE = {
      '-12:00' => %w[Y],
      '-11:00' => %w[X BST],
      '-10:00' => %w[W HST BDT],
      '-09:00' => %w[V YST HDT],
      '-08:00' => %w[U PST YDT],
      '-07:00' => %w[T MST PDT],
      '-06:00' => %w[S CST MDT],
      '-05:00' => %w[R EST CDT],
      '-04:00' => %w[Q AST EDT],
      '-03:00' => %w[P ADT],
      '-02:00' => %w[O],
      '-01:00' => %w[N],
      '+00:00' => %w[Z GMT WET],
      '+01:00' => %w[A CET BST],
      '+02:00' => %w[B EET],
      '+03:00' => %w[C],
      '+04:00' => %w[D],
      '+05:00' => %w[E],
      '+06:00' => %w[F],
      '+07:00' => %w[G],
      '+08:00' => %w[H SST WST],
      '+09:00' => %w[I JST],
      '+10:00' => %w[K JDT],
      '+11:00' => %w[L],
      '+12:00' => %w[M NZST],
      '+13:00' => %w[NZDT]
    }.freeze
  end
end
