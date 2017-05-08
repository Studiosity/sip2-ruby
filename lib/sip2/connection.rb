module Sip2
  #
  # Sip2 Connection
  #
  class Connection
    def initialize(socket, ignore_error_detection)
      @socket = socket
      @ignore_error_detection = ignore_error_detection
      @sequence = 1
    end

    def login(username, password, location_code = nil)
      login_message = build_login_message(username, password, location_code)
      response = send_message login_message
      login_successful? response
    end

    def patron_information(patron_uid, password)
      patron_message = build_patron_message(patron_uid, password)
      response = send_message patron_message
      return unless sequence_and_checksum_valid?(response)
      PatronInformation.new response
    end

    private

    def send_message(message)
      @socket.send(message + "\r", 0)
      @socket.gets "\r"
    end

    def with_error_detection_and_checksum(message)
      with_checksum with_error_detection message
    end

    def with_error_detection(message)
      message + '|AY' + @sequence.to_s
    end

    def with_checksum(message)
      message += 'AZ'
      message + checksum_for(message)
    end

    def checksum_for(message)
      check = 0
      message.each_char { |m| check += m.ord }
      check += "\0".ord
      check = (check ^ 0xFFFF) + 1
      format '%4.4X', check
    end

    def sequence_and_checksum_valid?(response)
      return true if @ignore_error_detection
      sequence_regex = /^(?<message>.*?AY(?<sequence>[0-9]+)AZ)(?<checksum>[A-F0-9]{4})$/
      match = response.strip.match sequence_regex
      match &&
        match[:sequence] == @sequence.to_s &&
        match[:checksum] == checksum_for(match[:message])
    ensure
      @sequence += 1
    end

    def build_login_message(username, password, location_code)
      code = '93' # Login
      uid_algorithm = pw_algorithm = '0' # Plain text
      username_field = 'CN' + username
      password_field = 'CO' + password
      location_code = location_code.strip if location_code.is_a? String
      location_field = location_code ? "|CP#{location_code}" : ''

      message = [
        code, uid_algorithm, pw_algorithm, username_field, '|', password_field, location_field
      ].join

      with_error_detection_and_checksum message
    end

    def login_successful?(response)
      sequence_and_checksum_valid?(response) && response[/^94([01])AY/, 1] == '1'
    end

    def build_patron_message(uid, password)
      code = '63' # Patron information
      language = '000' # Unknown
      timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
      summary = ' ' * 10
      message = "#{code}#{language}#{timestamp}#{summary}AO|AA#{uid}|AC|AD#{password}"
      with_error_detection_and_checksum message
    end
  end
end
