# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Messages::Login do
  subject(:login_message) { described_class.new(connection) }

  let(:connection) { instance_double 'Sip2::Connection' }

  describe '#action_message' do
    subject(:action_message) do
      login_message.action_message(username: username, password: password)
    end

    let(:username) { 'user_id' }
    let(:password) { 'passw0rd' }

    it 'sends a well formed login message to the connection' do
      allow(connection).to(
        receive(:send_message).
          with('9300CNuser_id|COpassw0rd').
          and_return('941AY1AZFDFC')
      )
      expect(connection).to receive(:send_message).with('9300CNuser_id|COpassw0rd')

      expect(action_message).to be_truthy
    end

    context 'when location code is provided' do
      subject(:action_message) do
        login_message.action_message(username: username, password: password, location_code: 'foo')
      end

      it 'sends a well formed login message to the connection' do
        allow(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd|CPfoo').
            and_return('941AY1AZFDFC')
        )
        expect(connection).to receive(:send_message).with('9300CNuser_id|COpassw0rd|CPfoo')

        expect(action_message).to be_truthy
      end
    end

    context 'when the server responds with login failure' do
      it 'returns false' do
        allow(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd').
            and_return('940AY1AZFDFD')
        )
        expect(connection).to receive(:send_message).with('9300CNuser_id|COpassw0rd')

        expect(action_message).to be_falsey
      end
    end
  end

  context 'when connecting to a "real" server' do
    let(:client) { Sip2::Client.new(host: '127.0.0.1', port: port) }
    let(:port) { 4321 }

    it 'calls through the connection with the login message' do
      with_server(port: port) do |server|
        server_message = nil

        Thread.new do
          client = server.accept
          server_message = client.gets "\r"
          client.write "941AY1AZFDFC\r"
          client.close
        end

        response = client.connect do |connection|
          connection.login username: 'user_name', password: 'pw0rd'
        end
        expect(response).to eq true
        expect(server_message).to eq "9300CNuser_name|COpw0rd|AY1AZF607\r"
      end
    end
  end
end
