# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Client do
  describe '#connect' do
    let(:client) { Sip2::Client.new(host: '127.0.0.1', port: 4321) }

    it 'yields sip connection' do
      socket = double
      expect(Sip2::NonBlockingSocket).to(
        receive(:connect).
          with('127.0.0.1', 4321, timeout: 5).
          and_return(socket)
      )
      expect(socket).to receive(:close)

      expect(OpenSSL::SSL::SSLSocket).not_to receive(:new)

      connection = double
      expect(Sip2::Connection).to(
        receive(:new).
          with(socket, false).
          and_return(connection)
      )
      expect { |block| client.connect(&block) }.to yield_with_args connection
    end

    context 'when overriding the port' do
      let(:client) { Sip2::Client.new(host: '123.123.123.123', port: 1234) }

      it 'passes the overridden port to socket initializer' do
        socket = double
        expect(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with('123.123.123.123', 1234, timeout: 5).
            and_return(socket)
        )
        expect(socket).to receive(:close)

        client.connect
      end
    end

    context 'when overriding error detection' do
      let(:client) { Sip2::Client.new(host: '', port: 1, ignore_error_detection: true) }

      it 'passes error detection flag to connection' do
        socket = double
        expect(Sip2::NonBlockingSocket).to receive(:connect).and_return socket
        expect(socket).to receive(:close)

        # Test is the second parameter of the Connection initializer
        expect(Sip2::Connection).to receive(:new).with(socket, true)

        client.connect {}
      end
    end

    context 'when overriding timeout' do
      let(:client) { Sip2::Client.new(host: '127.0.0.1', port: 567, timeout: 1122) }

      it 'passes the overridden timeout to socket initializer' do
        socket = double
        expect(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with('127.0.0.1', 567, timeout: 1122).
            and_return(socket)
        )
        expect(socket).to receive(:close)

        client.connect
      end
    end

    context 'when specifying an SSL context' do
      let(:client) { Sip2::Client.new(host: '127.0.0.1', port: port, ssl_context: ssl_context) }
      let(:ssl_context) { OpenSSL::SSL::SSLContext.new }
      let(:port) { 4321 }

      it 'yields sip connection' do
        socket = instance_double 'Sip2::NonBlockingSocket'
        expect(Sip2::NonBlockingSocket).to(
          receive(:connect).
            with('127.0.0.1', 4321, timeout: 5).
            and_return(socket)
        )

        ssl_socket = instance_double 'OpenSSL::SSL::SSLSocket'
        expect(OpenSSL::SSL::SSLSocket).to(
          receive(:new).
            with(socket, ssl_context).
            and_return(ssl_socket)
        )
        expect(ssl_socket).to receive(:sync_close=).with(true)
        expect(ssl_socket).to receive(:connect)

        expect(ssl_socket).to receive(:close)

        connection = instance_double 'Sip2::Connection'
        expect(Sip2::Connection).to(
          receive(:new).
            with(ssl_socket, false).
            and_return(connection)
        )
        expect { |block| client.connect(&block) }.to yield_with_args connection
      end

      it 'can connect to an SSL server' do
        with_ssl_server(port: port) do |server|
          Thread.new do
            client = server.accept
            client.write "hey there\r"
            client.close
          end

          response = client.connect { |connection| connection.send_message 'hi' }
          expect(response).to eq 'hey there'
        end
      end

      context 'when context verify mode is `VERIFY_PEER`' do
        before { ssl_context.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER) }

        it 'raises an SSL error when trying to connect' do
          with_ssl_server(port: port) do |server|
            Thread.new do
              expect { server.accept }.to(
                raise_error(
                  OpenSSL::SSL::SSLError,
                  /read client certificate A: tlsv1 alert unknown ca/
                )
              )
            end

            expect { client.connect }.to(
              raise_error(OpenSSL::SSL::SSLError, /certificate verify failed/)
            )
          end
        end

        context 'when the client context specifies the certificate' do
          before { ssl_context.ca_file = 'test_server/cert/ca-cert.pem' }

          it 'can connect to an SSL server' do
            with_ssl_server(port: port) do |server|
              Thread.new do
                client = server.accept
                client.write "hey there\r"
                client.close
              end

              response = client.connect { |connection| connection.send_message 'hi' }
              expect(response).to eq 'hey there'
            end
          end
        end
      end
    end
  end
end
