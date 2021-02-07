# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Connection do
  let(:socket) do
    instance_double(
      'NonBlockingSocket',
      write: nil, gets: "default-result\r", connection_timeout: nil
    )
  end
  let(:connection) { described_class.new(socket: socket, ignore_error_detection: false) }

  describe '#send_message' do
    subject(:send_message) { connection.send_message 'a message' }

    it 'calls to underlying socket `write` method with message, error detection, checksum' do
      expect(socket).to receive(:write).with("a message|AY1AZFAB8\r")
      send_message
    end

    it 'calls to underlying socket `gets` method and returns result' do
      allow(socket).to receive(:gets).with("\r").and_return "messageAY1AZFBB5\r"
      expect(socket).to receive(:gets).with "\r"
      expect(send_message).to eq 'messageAY1AZFBB5'
    end

    context 'when the returned message doesnt pass the checksum test' do
      it 'returns nil' do
        allow(socket).to receive(:gets).with("\r").and_return "messageAY11234\r"
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to be_nil
      end
    end

    context 'when the returned message has a leading newline character' do
      it 'strips the newline and returns result' do
        allow(socket).to receive(:gets).with("\r").and_return "\nmessageAY1AZFBB5\r"
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to eq 'messageAY1AZFBB5'
      end
    end

    context 'when the returned message has multiple leading newline characters' do
      it 'returns nil (fails the checksum)' do
        allow(socket).to receive(:gets).with("\r").and_return "\n\nmessageAY11234\r"
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to be_nil
      end
    end

    context 'when the socket is closed before response received (returns nil)' do
      it 'returns nil' do
        allow(socket).to receive(:gets).with("\r").and_return nil
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to be_nil
      end
    end

    context 'when the returned message has a sequence mismatch' do
      it 'returns nil' do
        allow(socket).to receive(:gets).with("\r").and_return "messageAY2AZFBB\r"
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to be_nil
      end
    end

    context 'when error detection is disabled' do
      let(:connection) { described_class.new(socket: socket, ignore_error_detection: true) }

      it 'returns the message even if the sequence is wrong' do
        allow(socket).to receive(:gets).with("\r").and_return "messageAY2AZFBB\r"
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to eq 'messageAY2AZFBB'
      end

      it 'returns the message even if the checksum is wrong' do
        allow(socket).to receive(:gets).with("\r").and_return "messageAY11234\r"
        expect(socket).to receive(:gets).with "\r"
        expect(send_message).to eq 'messageAY11234'
      end
    end

    describe 'write timeouts' do
      it 'doesnt timeout if write succeeds in less than 5 seconds' do
        expect(socket).to receive(:write) do
          sleep 4.8
        end
        expect { send_message }.not_to raise_error
      end

      it 'raises WriteTimeout if write takes more than 5 seconds' do
        expect(socket).to receive(:write) do
          sleep 5.2
        end
        expect { send_message }.to raise_error Sip2::WriteTimeout
      end
    end

    describe 'read timeouts' do
      it 'doesnt timeout if gets succeeds in less than 5 seconds' do
        expect(socket).to receive(:gets) do
          sleep 4.8
          "bar\r"
        end
        expect { send_message }.not_to raise_error
      end

      it 'raises ReadTimeout if gets takes more than 5 seconds' do
        expect(socket).to receive(:gets) do
          sleep 5.2
          "bar\r"
        end
        expect { send_message }.to raise_error Sip2::ReadTimeout
      end
    end
  end

  describe '#login' do
    it 'creates a Messages::Login and calls action_message' do
      login_message = instance_double 'Sip2::Messages::Login'
      allow(Sip2::Messages::Login).to(
        receive(:new).
          with(connection).
          and_return(login_message)
      )
      expect(Sip2::Messages::Login).to receive(:new).with(connection)

      expect(login_message).to(
        receive(:action_message).
          with(username: 'user_id', password: 'passw0rd')
      )

      connection.login(username: 'user_id', password: 'passw0rd')
    end
  end

  describe '#patron_information' do
    it 'creates a Messages::PatronInformation and calls action_message' do
      patron_information_message =
        instance_double 'Sip2::Messages::PatronInformation'
      allow(Sip2::Messages::PatronInformation).to(
        receive(:new).
          with(connection).
          and_return(patron_information_message)
      )
      expect(Sip2::Messages::PatronInformation).to receive(:new).with(connection)

      expect(patron_information_message).to(
        receive(:action_message).
          with(uid: 'user_uid', password: 'passw0rd')
      )

      connection.patron_information(uid: 'user_uid', password: 'passw0rd')
    end
  end
end
