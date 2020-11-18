# frozen_string_literal: true

module Sip2
  module Messages
    #
    # Sip2 Login message
    #
    # https://developers.exlibrisgroup.com/wp-content/uploads/2020/01/3M-Standard-Interchange-Protocol-Version-2.00.pdf
    #
    # Request message  93
    # Response message 94
    #
    class Login < Base
      private

      def build_message(username:, password:, location_code: nil)
        code = '93' # Login
        uid_algorithm = pw_algorithm = '0' # Plain text
        username_field = "CN#{username}"
        password_field = "CO#{password}"
        location_code = location_code.strip if location_code.is_a? String
        location_field = location_code ? "|CP#{location_code}" : ''

        [
          code, uid_algorithm, pw_algorithm, username_field, '|', password_field, location_field
        ].join
      end

      def handle_response(response)
        response[/\A94([01])AY/, 1] == '1'
      end
    end
  end
end
