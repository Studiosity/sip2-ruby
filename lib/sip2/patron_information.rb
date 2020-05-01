# frozen_string_literal: true

module Sip2
  #
  # Sip2 Patron Information
  #
  class PatronInformation
    attr_reader :raw_response

    def initialize(patron_response)
      @raw_response = patron_response
    end

    def charge_privileges_denied?
      parse_patron_status 0
    end

    def renewal_privileges_denied?
      parse_patron_status 1
    end

    def recall_privileges_denied?
      parse_patron_status 2
    end

    def hold_privileges_denied?
      parse_patron_status 3
    end

    def card_reported_lost?
      parse_patron_status 4
    end

    def too_many_items_charged?
      parse_patron_status 5
    end

    def too_many_items_overdue?
      parse_patron_status 6
    end

    def too_many_renewals?
      parse_patron_status 7
    end

    def too_many_claims_of_items_returned?
      parse_patron_status 8
    end

    def too_many_items_lost?
      parse_patron_status 9
    end

    def excessive_outstanding_fines?
      parse_patron_status 10
    end

    def excessive_outstanding_fees?
      parse_patron_status 11
    end

    def recall_overdue?
      parse_patron_status 12
    end

    def too_many_items_billed?
      parse_patron_status 13
    end

    def language
      LANGUAGE_LOOKUP_TABLE[parse_fixed_response(14, 3)]
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
      parse_boolean 'BL'
    end

    def authenticated?
      parse_boolean 'CQ'
    end

    def email
      parse_text 'BE'
    end

    def location
      parse_text 'AQ'
    end

    def screen_message
      parse_text 'AF'
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

    def parse_boolean(message_id)
      raw_response[/\|#{message_id}([YN])\|/, 1] == 'Y'
    end

    def parse_text(message_id)
      raw_response[/\|#{message_id}(.*?)\|/, 1]
    end

    def parse_patron_status(position)
      parse_fixed_response(position) == 'Y'
    end

    def parse_fixed_response(position, count = 1)
      raw_response[/\A64.{#{position}}(.{#{count}})/, 1]
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

    LANGUAGE_LOOKUP_TABLE = {
      '000' => 'Unknown',
      '001' => 'English',
      '002' => 'French',
      '003' => 'German',
      '004' => 'Italian',
      '005' => 'Dutch',
      '006' => 'Swedish',
      '007' => 'Finnish',
      '008' => 'Spanish',
      '009' => 'Danish',
      '010' => 'Portuguese',
      '011' => 'Canadian-French',
      '012' => 'Norwegian',
      '013' => 'Hebrew',
      '014' => 'Japanese',
      '015' => 'Russian',
      '016' => 'Arabic',
      '017' => 'Polish',
      '018' => 'Greek',
      '019' => 'Chinese',
      '020' => 'Korean',
      '021' => 'North American Spanish',
      '022' => 'Tamil',
      '023' => 'Malay',
      '024' => 'United Kingdom',
      '025' => 'Icelandic',
      '026' => 'Belgian',
      '027' => 'Taiwanese'
    }.freeze
  end
end
