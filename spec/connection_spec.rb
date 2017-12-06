require 'spec_helper'

describe Sip2::Connection do
  let(:socket) { double }
  let(:connection) { Sip2::Connection.new(socket, false) }

  describe '#login' do
    it 'sends a well formed login packet to socket' do
      expect(socket).to receive(:send).with("9300CNuser_id|COpassw0rd|AY1AZF594\r", 0)
      expect(socket).to receive(:gets).with("\r").and_return "941AY1AZFDFC\r"

      expect(connection.login('user_id', 'passw0rd')).to be_truthy
    end

    context 'location code is provided' do
      it 'sends a well formed login packet to socket' do
        expect(socket).to receive(:send).with("9300CNuser_id|COpassw0rd|CPfoo|AY1AZF341\r", 0)
        expect(socket).to receive(:gets).with("\r").and_return "941AY1AZFDFC\r"

        expect(connection.login('user_id', 'passw0rd', 'foo')).to be_truthy
      end
    end

    context 'error detection is disabled' do
      let(:connection) { Sip2::Connection.new(socket, true) }

      it 'returns true even if the checksum is wrong' do
        expect(socket).to receive(:send).with("9300CNuser_id|COpassw0rd|AY1AZF594\r", 0)
        expect(socket).to receive(:gets).with("\r").and_return "941AY6AZABCD\r"

        expect(connection.login('user_id', 'passw0rd')).to be_truthy
      end
    end

    context 'server responds with login failure' do
      it 'returns false' do
        expect(socket).to receive(:send).with("9300CNuser_id|COpassw0rd1|AY1AZF563\r", 0)
        expect(socket).to receive(:gets).with("\r").and_return "940AY1AZFDFD\r"

        expect(connection.login('user_id', 'passw0rd1')).to be_falsey
      end
    end
  end

  describe '#patron_information' do
    it 'sends a well formed patron information packet to socket' do
      Timecop.freeze do
        timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request = request + checksum(request) + "\r"
        expect(socket).to receive(:send).with request, 0

        response = '64FOOBAR|AY1AZFBFB'
        expect(socket).to receive(:gets).with("\r").and_return response

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_a Sip2::Responses::PatronInformation
        expect(info.raw_response).to eq response
      end
    end

    context 'error detection is disabled' do
      let(:connection) { Sip2::Connection.new(socket, true) }

      it 'returns patron information even if the checksum is wrong' do
        Timecop.freeze do
          timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
          request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
          request = request + checksum(request) + "\r"
          expect(socket).to receive(:send).with request, 0

          response = '64FOOBAR|AY1AZABCD'
          expect(socket).to receive(:gets).with("\r").and_return response

          info = connection.patron_information('user_uid', 'passw0rd')
          expect(info).to be_a Sip2::Responses::PatronInformation
          expect(info.raw_response).to eq response
        end
      end
    end

    context 'server responds with invalid packet' do
      it 'returns nil' do
        timestamp = Time.now.strftime('%Y%m%d    %H%M%S')
        request = "63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd|AY1AZ"
        request = request + checksum(request) + "\r"
        expect(socket).to receive(:send).with request, 0
        expect(socket).to receive(:gets).with("\r").and_return '64FOOBAR|AY1AZABCD'

        info = connection.patron_information('user_uid', 'passw0rd')
        expect(info).to be_nil
      end
    end
  end

  describe '#build_patron_status_message' do
    around do |example|
      Timecop.freeze('2020-01-01 00:00:00') do
        example.run
      end
    end

    let(:username) { 'username' }
    let(:pin) { 'pin' }

    let(:valid_patron_status_line) { '2300020200101    000000AO|AAusername|AC|ADpin' }
    let(:valid_patron_status_line_blank_pin) { '2300020200101    000000AO|AAusername|AC|AD' }
    let(:valid_patron_status_line_no_pin) { '2300020200101    000000AO|AAusername|AC' }

    subject { connection.send(:build_patron_status_message, username, pin) }

    it 'builds the correct string' do
      expect(subject).to eq(valid_patron_status_line)
    end
    context 'given a blank password/pin' do
      let(:pin) { '' }
      it 'adds the password field' do
        expect(subject).to eq(valid_patron_status_line_blank_pin)
      end
    end
    context 'given a nil password' do
      let(:pin) { nil }
      it 'does not send the password field' do
        expect(subject).to eq(valid_patron_status_line_no_pin)
      end
    end
  end

  describe '#handle_patron_status_response' do
    let(:response) { double(:response) }
    subject { connection.send(:handle_patron_status_response, response) }

    context 'if sequence_and_checksum_valid? returns false' do
      before do
        expect(connection).to receive(
          :sequence_and_checksum_valid?
        ).with(response) { false }
      end
      it 'should return nil' do
        expect(subject).to be nil
      end
    end

    context 'if sequence_and_checksum_valid? returns true' do
      before do
        expect(connection).to receive(
          :sequence_and_checksum_valid?
        ).with(response) { true }
      end
      it 'returns a PatronStatus response object' do
        response_object = double(:response_object)
        expect(Sip2::Responses::PatronStatus).to receive(:new) { response_object }
        expect(subject).to eq response_object
      end
    end
  end

  def checksum(message)
    check = 0
    message.each_char { |m| check += m.ord }
    check += "\0".ord
    check = (check ^ 0xFFFF) + 1
    format '%4.4X', check
  end
end
