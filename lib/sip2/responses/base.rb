# frozen_string_literal: true

module Sip2
  module Responses
    #
    # Sip2 Base response
    #
    class Base
      attr_reader :raw_response

      def initialize(raw_response)
        @raw_response = raw_response
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

      protected

      DATE_MATCH_REGEX = '(\d{4})(\d{2})(\d{2})(.{4})(\d{2})(\d{2})(\d{2})'

      def parse_fixed_response(position, count = 1)
        raw_response[/\A#{self.class::RESPONSE_ID}.{#{position}}(.{#{count}})/, 1]
      end

      def parse_fixed_boolean(position)
        parse_fixed_response(position) == 'Y'
      end

      def parse_optional_boolean(message_id)
        raw_response[/\|#{message_id}([YN])\|/, 1] == 'Y'
      end

      def parse_text(message_id)
        raw_response[/\|#{message_id}(.*?)\|/, 1]
      end

      def parse_datetime(position) # rubocop:disable Metrics/AbcSize
        match = raw_response.match(/\A#{self.class::RESPONSE_ID}.{#{position}}#{DATE_MATCH_REGEX}/)
        return unless match

        _, year, month, day, zone, hour, minute, second = match.to_a
        Time.new(
          year.to_i, month.to_i, day.to_i,
          hour.to_i, minute.to_i, second.to_i,
          offset_from_zone(zone)
        )
      end

      def offset_from_zone(zone)
        zone.strip!
        lookup = TIME_ZONE_LOOKUP_TABLE.find { |_, v| v.include? zone }
        lookup ? lookup.first : '+00:00'
      end
    end
  end
end
