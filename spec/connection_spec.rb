# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Connection do
  let(:socket) { double }
  let(:connection) { Sip2::Connection.new(socket, false) }

  describe '#login' do
    it 'sends a well formed login packet to socket' do
      expect(socket).to receive(:send_with_timeout).with '9300CNuser_id|COpassw0rd|AY1AZF594'
      expect(socket).to receive(:gets_with_timeout).and_return "941AY1AZFDFC\r"

      expect(connection.login('user_id', 'passw0rd')).to be_truthy
    end

    context 'location code is provided' do
      it 'sends a well formed login packet to socket' do
        expect(socket).to(
          receive(:send_with_timeout).with('9300CNuser_id|COpassw0rd|CPfoo|AY1AZF341')
        )
        expect(socket).to receive(:gets_with_timeout).and_return "941AY1AZFDFC\r"

        expect(connection.login('user_id', 'passw0rd', 'foo')).to be_truthy
      end
    end

    context 'error detection is disabled' do
      let(:connection) { Sip2::Connection.new(socket, true) }

      it 'returns true even if the checksum is wrong' do
        expect(socket).to receive(:send_with_timeout).with '9300CNuser_id|COpassw0rd|AY1AZF594'
        expect(socket).to receive(:gets_with_timeout).and_return "941AY6AZABCD\r"

        expect(connection.login('user_id', 'passw0rd')).to be_truthy
      end
    end

    context 'server responds with login failure' do
      it 'returns false' do
        expect(socket).to receive(:send_with_timeout).with '9300CNuser_id|COpassw0rd1|AY1AZF563'
        expect(socket).to receive(:gets_with_timeout).and_return "940AY1AZFDFD\r"

        expect(connection.login('user_id', 'passw0rd1')).to be_falsey
      end
    end
  end

  describe '#patron_information' do
    it 'sends a well formed patron information packet to socket' do
      Timecop.freeze do
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request += checksum(request)
        expect(socket).to receive(:send_with_timeout).with request

        response = '64FOOBAR|AY1AZFBFB'
        expect(socket).to receive(:gets_with_timeout).and_return response

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
          expect(socket).to receive(:send_with_timeout).with request

          response = '64FOOBAR|AY1AZABCD'
          expect(socket).to receive(:gets_with_timeout).and_return response

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
        expect(socket).to receive(:send_with_timeout).with request
        expect(socket).to receive(:gets_with_timeout).and_return '64FOOBAR|AY1AZABCD'

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_nil
      end
    end

    context 'socket closed before response received' do
      it 'returns nil' do
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request += checksum(request)
        expect(socket).to receive(:send_with_timeout).with request
        expect(socket).to receive(:gets_with_timeout).and_return nil

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_nil
      end
    end

    context 'a terminal password is provided' do
      it 'sends a well formed patron information packet to socket' do
        Timecop.freeze do
          request = "63000#{timestamp}          AO|AAuser_uid|ACt3rmp4ss|ADpassw0rd|AY1AZ"
          request += checksum(request)
          expect(socket).to receive(:send_with_timeout).with request

          response = '64FOOBAR|AY1AZFBFB'
          expect(socket).to receive(:gets_with_timeout).and_return response

          info = connection.patron_information('user_uid', 'passw0rd', 't3rmp4ss')
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
