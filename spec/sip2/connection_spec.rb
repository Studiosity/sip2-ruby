# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Connection do
  let(:socket) do
    instance_double(
      'NonBlockingSocket',
      write: nil, gets: "default-result\r", connection_timeout: nil
    )
  end
  let(:connection) { Sip2::Connection.new(socket, false) }

  describe '#send_message' do
    subject(:send_message) { connection.send_message 'a message' }

    describe 'write timeouts' do
      it 'calls to underlying socket `write` method with message and trailing carriage return' do
        expect(socket).to receive(:write).with("a message\r")
        send_message
      end

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
      it 'calls to underlying socket `gets` method and returns result' do
        expect(socket).to receive(:gets).with("\r").and_return "bar\r"
        expect(send_message).to eq 'bar'
      end

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
    it 'sends a well formed login packet to socket' do
      expect(connection).to(
        receive(:send_message).
          with('9300CNuser_id|COpassw0rd|AY1AZF594').
          and_return('941AY1AZFDFC')
      )

      expect(connection.login('user_id', 'passw0rd')).to be_truthy
    end

    context 'location code is provided' do
      it 'sends a well formed login packet to socket' do
        expect(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd|CPfoo|AY1AZF341').
            and_return('941AY1AZFDFC')
        )

        expect(connection.login('user_id', 'passw0rd', location_code: 'foo')).to be_truthy
      end
    end

    context 'error detection is disabled' do
      let(:connection) { Sip2::Connection.new(socket, true) }

      it 'returns true even if the checksum is wrong' do
        expect(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd|AY1AZF594').
            and_return('941AY6AZABCD')
        )

        expect(connection.login('user_id', 'passw0rd')).to be_truthy
      end
    end

    context 'server responds with login failure' do
      it 'returns false' do
        expect(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd1|AY1AZF563').
            and_return('940AY1AZFDFD')
        )

        expect(connection.login('user_id', 'passw0rd1')).to be_falsey
      end
    end
  end

  describe '#patron_information' do
    it 'sends a well formed patron information packet' do
      Timecop.freeze do
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request += checksum(request)
        response = '64FOOBAR|AY1AZFBFB'

        expect(connection).to receive(:send_message).with(request).and_return response

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_a Sip2::PatronInformation
        expect(info.raw_response).to eq response
      end
    end

    context 'error detection is disabled' do
      let(:connection) { Sip2::Connection.new(socket, true) }

      it 'returns patron information even if the checksum is wrong' do
        Timecop.freeze do
          request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
          request += checksum(request)
          response = '64FOOBAR|AY1AZABCD'

          expect(connection).to receive(:send_message).with(request).and_return response

          info = connection.patron_information('user_uid', 'passw0rd')
          expect(info).to be_a Sip2::PatronInformation
          expect(info.raw_response).to eq response
        end
      end
    end

    context 'server responds with invalid packet' do
      it 'returns nil' do
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request += checksum(request)
        expect(connection).to receive(:send_message).with(request).and_return '64FOOBAR|AY1AZABCD'

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_nil
      end
    end

    context 'socket closed before response received' do
      it 'returns nil' do
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request += checksum(request)

        expect(connection).to receive(:send_message).with(request).and_return nil

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_nil
      end
    end

    context 'a terminal password is provided' do
      it 'sends a well formed patron information packet to socket' do
        Timecop.freeze do
          request = "63000#{timestamp}          AO|AAuser_uid|ACt3rmp4ss|ADpassw0rd|AY1AZ"
          request += checksum(request)
          response = '64FOOBAR|AY1AZFBFB'

          expect(connection).to receive(:send_message).with(request).and_return response

          info =
            connection.patron_information('user_uid', 'passw0rd', terminal_password: 't3rmp4ss')
          expect(info).to be_a Sip2::PatronInformation
          expect(info.raw_response).to eq response
        end
      end
    end
  end

  def checksum(message)
    check = 0
    message.each_char { |m| check += m.ord }
    check += "\0".ord
    check = (check ^ 0xFFFF) + 1
    format '%<check>4.4X', check: check
  end

  def timestamp
    Time.now.strftime('%Y%m%d    %H%M%S')
  end
end
