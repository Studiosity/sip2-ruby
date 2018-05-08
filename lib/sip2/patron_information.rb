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
      offset = offset_from_zone(zone)
      DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, second.to_i, offset)
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
      lookup ? lookup.first : '0'
    end

    TIME_ZONE_LOOKUP_TABLE = {
      '-12' => %w[Y],
      '-11' => %w[X BST],
      '-10' => %w[W HST BDT],
      '-9' => %w[V YST HDT],
      '-8' => %w[U PST YDT],
      '-7' => %w[T MST PDT],
      '-6' => %w[S CST MDT],
      '-5' => %w[R EST CDT],
      '-4' => %w[Q AST EDT],
      '-3' => %w[P ADT],
      '-2' => %w[O],
      '-1' => %w[N],
      '0' => %w[Z GMT WET],
      '+1' => %w[A CET BST],
      '+2' => %w[B EET],
      '+3' => %w[C],
      '+4' => %w[D],
      '+5' => %w[E],
      '+6' => %w[F],
      '+7' => %w[G],
      '+8' => %w[H SST WST],
      '+9' => %w[I JST],
      '+10' => %w[K JDT],
      '+11' => %w[L],
      '+12' => %w[M NZST],
      '+13' => %w[NZDT],
    }.freeze
  end
end
