# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Client do
  describe '#connect' do
    let(:client) { Sip2::Client.new(host: '127.0.0.1', port: 4321) }

    it 'yields sip connection' do
      socket = double
      expect(Sip2::NonBlockingSocket).to receive(:connect)
        .with('127.0.0.1', 4321, 5).and_return socket
      expect(socket).to receive(:close)

      connection = double
      expect(Sip2::Connection).to receive(:new)
        .with(socket, false).and_return connection
      expect { |block| client.connect(&block) }.to yield_with_args connection
    end

    context 'overriding the port' do
      let(:client) { Sip2::Client.new(host: '123.123.123.123', port: 1234) }

      it 'passes the overridden port to socket initializer' do
        socket = double
        expect(Sip2::NonBlockingSocket).to receive(:connect)
          .with('123.123.123.123', 1234, 5).and_return socket
        expect(socket).to receive(:close)

        client.connect
      end
    end

    context 'overriding error detection' do
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

    context 'overriding timeout' do
      let(:client) { Sip2::Client.new(host: '127.0.0.1', port: 567, timeout: 1122) }

      it 'passes the overridden timeout to socket initializer' do
        socket = double
        expect(Sip2::NonBlockingSocket).to receive(:connect)
          .with('127.0.0.1', 567, 1122).and_return socket
        expect(socket).to receive(:close)

        client.connect
      end
    end
  end
end
