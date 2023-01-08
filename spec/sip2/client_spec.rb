# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Client do
  describe '#connect' do
    let(:client) { described_class.new(host: '127.0.0.1', port: port) }
    let(:port) { 4321 }

    it 'yields sip connection' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      socket = instance_double Sip2::NonBlockingSocket
      allow(Sip2::NonBlockingSocket).to(
        receive(:connect).
          with(host: '127.0.0.1', port: 4321, timeout: 5).
          and_return(socket)
      )
      expect(Sip2::NonBlockingSocket).to(
        receive(:connect).
          with(host: '127.0.0.1', port: 4321, timeout: 5)
      )
      expect(socket).to receive(:close)

      expect(OpenSSL::SSL::SSLSocket).not_to receive(:new)

      connection = instance_double Sip2::Connection
      allow(Sip2::Connection).to(
        receive(:new).
          with(socket: socket, ignore_error_detection: false).
          and_return(connection)
      )
      expect(Sip2::Connection).to(
        receive(:new).
          with(socket: socket, ignore_error_detection: false)
      )
      expect { |block| client.connect(&block) }.to yield_with_args connection
    end

    it 'can connect to a server' do
      with_server(port: port) do |server|
        Thread.new do
          client = server.accept
          client.write "hey thereAY1AZFB1C\r"
          client.close
        end

        response = client.connect { |connection| connection.send_message 'hi' }
        expect(response).to eq 'hey thereAY1AZFB1C'
      end
    end

    context 'when the server responds with invalid packet' do
      it 'returns nil' do
        with_server(port: port) do |server|
          Thread.new do
            client = server.accept
            client.write "64FOOBAR|AY1AZABCD\r"
            client.close
          end

          response = client.connect { |connection| connection.send_message 'hi' }
          expect(response).to be_nil
        end
      end
    end

    context 'when overriding the port' do
      let(:client) { described_class.new(host: '123.123.123.123', port: 1234) }

      it 'passes the overridden port to socket initializer' do
        socket = instance_double Sip2::NonBlockingSocket
        allow(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with(host: '123.123.123.123', port: 1234, timeout: 5).
            and_return(socket)
        )
        expect(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with(host: '123.123.123.123', port: 1234, timeout: 5)
        )
        expect(socket).to receive(:close)

        client.connect
      end
    end

    context 'when overriding error detection' do
      let(:client) { described_class.new(host: '', port: 1, ignore_error_detection: true) }

      it 'passes error detection flag to connection' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
        socket = instance_double Sip2::NonBlockingSocket
        allow(Sip2::NonBlockingSocket).to receive(:connect).and_return socket
        expect(Sip2::NonBlockingSocket).to receive(:connect)
        expect(socket).to receive(:close)

        # Test is the second parameter of the Connection initializer
        connection = instance_double Sip2::Connection
        allow(Sip2::Connection).to(
          receive(:new).
            with(socket: socket, ignore_error_detection: true).
            and_return(connection)
        )
        expect(Sip2::Connection).to(
          receive(:new).
            with(socket: socket, ignore_error_detection: true)
        )

        client.connect do |yielded_connection|
          expect(yielded_connection).to eq connection
        end
      end
    end

    context 'when overriding timeout' do
      let(:client) { described_class.new(host: '127.0.0.1', port: 567, timeout: 1122) }

      it 'passes the overridden timeout to socket initializer' do
        socket = instance_double Sip2::NonBlockingSocket
        allow(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with(host: '127.0.0.1', port: 567, timeout: 1122).
            and_return(socket)
        )
        expect(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with(host: '127.0.0.1', port: 567, timeout: 1122)
        )
        expect(socket).to receive(:close)

        client.connect
      end
    end

    context 'when specifying an SSL context' do
      let(:client) { described_class.new(host: host, port: port, ssl_context: ssl_context) }
      let(:ssl_context) { OpenSSL::SSL::SSLContext.new }
      let(:host) { 'sip2test.mooo.com' }

      it 'yields sip connection' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
        socket = instance_double Sip2::NonBlockingSocket
        allow(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with(host: 'sip2test.mooo.com', port: 4321, timeout: 5).
            and_return(socket)
        )
        expect(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with(host: 'sip2test.mooo.com', port: 4321, timeout: 5)
        )

        ssl_socket = instance_double OpenSSL::SSL::SSLSocket
        allow(OpenSSL::SSL::SSLSocket).to(
          receive(:new).
            with(socket, ssl_context).
            and_return(ssl_socket)
        )
        expect(OpenSSL::SSL::SSLSocket).to(
          receive(:new).
            with(socket, ssl_context)
        )
        expect(ssl_socket).to receive(:hostname=).with 'sip2test.mooo.com'
        expect(ssl_socket).to receive(:sync_close=).with true
        expect(ssl_socket).to receive(:connect)
        expect(ssl_socket).to receive(:post_connection_check).with 'sip2test.mooo.com'

        expect(ssl_socket).to receive(:close)

        connection = instance_double Sip2::Connection
        allow(Sip2::Connection).to(
          receive(:new).
            with(socket: ssl_socket, ignore_error_detection: false).
            and_return(connection)
        )
        expect(Sip2::Connection).to(
          receive(:new).
            with(socket: ssl_socket, ignore_error_detection: false)
        )
        expect { |block| client.connect(&block) }.to yield_with_args connection
      end

      it 'can connect to an SSL server' do
        with_ssl_server(port: port) do |server|
          Thread.new do
            client = server.accept
            client.write "hey thereAY1AZFB1C\r"
            client.close
          end

          response = client.connect { |connection| connection.send_message 'hi' }
          expect(response).to eq 'hey thereAY1AZFB1C'
        end
      end

      context 'when the host doesnt match the certificate' do
        let(:host) { 'sip2error.mooo.com' }

        it 'can connect to an SSL server' do
          with_ssl_server(port: port) do |server|
            Thread.new do
              server.accept
            end

            expect { client.connect }.to(
              raise_error(
                OpenSSL::SSL::SSLError,
                'hostname "sip2error.mooo.com" does not match the server certificate'
              )
            )
          end
        end
      end

      context 'when the host is an IP address' do
        let(:host) { '127.0.0.1' }

        it 'can connect to an SSL server' do
          with_ssl_server(port: port) do |server|
            Thread.new do
              server.accept
            end

            expect { client.connect }.to(
              raise_error(
                OpenSSL::SSL::SSLError,
                'hostname "127.0.0.1" does not match the server certificate'
              )
            )
          end
        end
      end

      context 'when context verify mode is `VERIFY_PEER`' do
        before { ssl_context.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER) }

        it 'raises an SSL error when trying to connect' do
          with_ssl_server(port: port) do |server|
            Thread.new do
              expect { server.accept }.to(
                raise_error(OpenSSL::SSL::SSLError, /tlsv1 alert unknown ca/)
              )
            end

            expect { client.connect }.to(
              raise_error(OpenSSL::SSL::SSLError, /certificate verify failed/)
            )
          end
        end

        context 'when the client context specifies the certificate' do
          before { ssl_context.ca_file = 'test_server/cert/ca-cert.crt' }

          it 'can connect to an SSL server' do
            with_ssl_server(port: port) do |server|
              Thread.new do
                client = server.accept
                client.write "hey thereAY1AZFB1C\r"
                client.close
              end

              response = client.connect { |connection| connection.send_message 'hi' }
              expect(response).to eq 'hey thereAY1AZFB1C'
            end
          end
        end
      end
    end
  end
end
