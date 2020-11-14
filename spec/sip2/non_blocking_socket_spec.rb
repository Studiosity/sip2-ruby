# frozen_string_literal: true

require 'spec_helper'

describe Sip2::NonBlockingSocket do
  subject(:socket) { Sip2::NonBlockingSocket.new(:INET, :STREAM) }

  it { is_expected.to be_a Socket }

  describe '.connect' do
    subject(:connect_socket) { Sip2::NonBlockingSocket.connect(host, port) }

    let(:host) { '127.0.0.1' }
    let(:port) { 51_337 }

    it 'initialises non-blocking socket' do
      with_server(port: port) do
        expect(Sip2::NonBlockingSocket).to(
          receive(:new).with(Socket::AF_INET, Socket::SOCK_STREAM, 0).and_call_original
        )
        expect(connect_socket).to be_a Sip2::NonBlockingSocket
      end
    end

    it 'assigns the default timeout to the connection timeout' do
      with_server(port: port) do
        expect(connect_socket.connection_timeout).to eq Sip2::NonBlockingSocket::DEFAULT_TIMEOUT
      end
    end

    context 'when the socket timeout is specified' do
      subject(:connect_socket) { Sip2::NonBlockingSocket.connect(host, port, timeout: 4321) }

      it 'assigns override to the connection timeout' do
        with_server(port: port) do
          expect(connect_socket.connection_timeout).to eq 4321
        end
      end
    end

    it 'sets the connection timeout' do
      with_server(port: port) { expect(subject.connection_timeout).to eq 5 }
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
      with_server(port: port) do |server|
        Thread.new do
          client = server.accept
          client.write "hey there\r"
          client.close
        end

        response = connect_socket.gets
        expect(response).to eq "hey there\r"
      end
    end
  end
end
