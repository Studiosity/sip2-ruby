# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Login message module
    #
    module Login
      def self.included(klass)
        klass.add_connection_module :login
      end

      private

      def build_login_message(username, password, location_code: nil)
        code = '93' # Login
        uid_algorithm = pw_algorithm = '0' # Plain text
        username_field = 'CN' + username
        password_field = 'CO' + password
        location_code = location_code.strip if location_code.is_a? String
        location_field = location_code ? "|CP#{location_code}" : ''

        [
          code, uid_algorithm, pw_algorithm, username_field, '|', password_field, location_field
        ].join
      end

      def handle_login_response(response)
        sequence_and_checksum_valid?(response) && response[/\A94([01])AY/, 1] == '1'
      end
    end
  end
end
