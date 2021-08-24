# frozen_string_literal: true

module TestServers
  def with_server(port:, &block)
    TCPServer.open(port, &block)
  end

  def with_ssl_server(port:)
    TCPServer.open(port) do |server|
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.cert =
        OpenSSL::X509::Certificate.new(File.open('test_server/cert/sip2test.mooo.com.crt'))
      ssl_context.key = OpenSSL::PKey::RSA.new(File.open('test_server/cert/sip2test.mooo.com.key'))
      ssl_server = OpenSSL::SSL::SSLServer.new(server, ssl_context)

      yield ssl_server
      ssl_server.close
    end
  end
end

RSpec.configure do |config|
  config.include TestServers
end
