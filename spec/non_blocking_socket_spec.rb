# frozen_string_literal: true

require 'spec_helper'

describe Sip2::NonBlockingSocket do
  subject(:socket) { Sip2::NonBlockingSocket.new(:INET, :STREAM) }

  describe '#send_with_timeout' do
    it 'calls to underlying socket `send` method with message and default flags' do
      expect(socket).to receive(:send).with("foo\r", 0)
      socket.send_with_timeout 'foo'
    end

    it 'doesnt timeout if send succeeds in less than 5 seconds' do
      expect(socket).to receive(:send) do
        sleep 4.8
      end
      expect { socket.send_with_timeout 'foo' }.not_to raise_error
    end

    it 'raises WriteTimeout if send takes more than 5 seconds' do
      expect(socket).to receive(:send) do
        sleep 5.2
      end
      expect { socket.send_with_timeout 'foo' }.to raise_error Sip2::WriteTimeout
    end
  end

  describe '#gets_with_timeout' do
    it 'calls to underlying socket `gets` method and returns result' do
      expect(socket).to receive(:gets).with("\r").and_return "bar\r"
      expect(socket.gets_with_timeout).to eq "bar\r"
    end

    it 'doesnt timeout if gets succeeds in less than 5 seconds' do
      expect(socket).to receive(:gets) do
        sleep 4.8
      end
      expect { socket.gets_with_timeout }.not_to raise_error
    end

    it 'raises ReadTimeout if gets takes more than 5 seconds' do
      expect(socket).to receive(:gets) do
        sleep 5.2
      end
      expect { socket.gets_with_timeout }.to raise_error Sip2::ReadTimeout
    end
  end

  describe '.connect' do
    subject(:connect_socket) { Sip2::NonBlockingSocket.connect(host, port) }

    let(:host) { '127.0.0.1' }
    let(:port) { 51_337 }

    it 'initialises non-blocking socket' do
      with_server do
        expect(Sip2::NonBlockingSocket).to(
          receive(:new).with(Socket::AF_INET, Socket::SOCK_STREAM, 0).and_call_original
        )
        connect_socket
      end
    end

    it 'assigns the default timeout to the connection timeout' do
      with_server do
        expect(connect_socket.connection_timeout).to eq Sip2::NonBlockingSocket::DEFAULT_TIMEOUT
      end
    end

    context 'when the socket timeout is specified' do
      subject(:connect_socket) { Sip2::NonBlockingSocket.connect(host, port, 4321) }

      it 'assigns override to the connection timeout' do
        with_server do
          expect(connect_socket.connection_timeout).to eq 4321
        end
      end
    end

    it 'sets the connection timeout' do
      with_server { expect(subject.connection_timeout).to eq 5 }
    end

    it 'raises connection refused (if there is no server to connect to)' do
      expect { connect_socket }.to raise_error Errno::ECONNREFUSED
    end

    context 'when the host isnt reachable' do
      # Host either won't exist, or for Travis is an iptables blackhole
      let(:host) { '127.0.0.2' }

      it 'raises a connection timeout' do
        expect { connect_socket }.to raise_error Sip2::ConnectionTimeout
      end
    end

    it 'can receive information from the server' do
      with_server do |server|
        Thread.new do
          client = server.accept
          client.send "hey there\r", 0
          client.close
        end

        response = connect_socket.gets_with_timeout
        expect(response).to eq "hey there\r"
      end
    end

    def with_server
      TCPServer.open(port) do |server|
        yield server
      end
    end
  end
end
