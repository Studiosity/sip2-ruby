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
      expect(connection).to(
        receive(:send_message).
          with('9300CNuser_id|COpassw0rd').
          and_return('941AY1AZFDFC')
      )

      expect(action_message).to be_truthy
    end

    context 'location code is provided' do
      subject(:action_message) do
        login_message.action_message(username: username, password: password, location_code: 'foo')
      end

      it 'sends a well formed login message to the connection' do
        expect(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd|CPfoo').
            and_return('941AY1AZFDFC')
        )

        expect(action_message).to be_truthy
      end
    end

    context 'server responds with login failure' do
      it 'returns false' do
        expect(connection).to(
          receive(:send_message).
            with('9300CNuser_id|COpassw0rd').
            and_return('940AY1AZFDFD')
        )

        expect(action_message).to be_falsey
      end
    end
  end
end
