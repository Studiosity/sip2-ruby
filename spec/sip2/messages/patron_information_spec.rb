# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Messages::PatronInformation do
  subject(:patron_information_message) { described_class.new(connection) }

  let(:connection) { instance_double 'Sip2::Connection' }

  describe '#action_message' do
    subject(:action_message) do
      patron_information_message.action_message(uid: username, password: password)
    end

    let(:username) { 'user_uid' }
    let(:password) { 'passw0rd' }

    it 'sends a well formed patron information packet' do
      Timecop.freeze do
        response = '64FOOBAR|AY1AZFBFB'

        expect(connection).to(
          receive(:send_message).
            with("63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd").
            and_return(response)
        )

        expect(action_message).to be_a Sip2::Responses::PatronInformation
        expect(action_message.raw_response).to eq response
      end
    end

    context 'when the connection doesnt return a message' do
      it 'returns nil' do
        expect(connection).to(
          receive(:send_message).
            with("63000#{timestamp}          AO|AAuser_uid|AC|ADpassw0rd").
            and_return(nil)
        )

        expect(action_message).to be_nil
      end
    end

    context 'a terminal password is provided' do
      subject(:action_message) do
        patron_information_message.
          action_message(uid: username, password: password, terminal_password: 't3rmp4ss')
      end

      it 'sends a well formed patron information packet to socket' do
        Timecop.freeze do
          response = '64FOOBAR|AY1AZFBFB'

          expect(connection).to(
            receive(:send_message).
              with("63000#{timestamp}          AO|AAuser_uid|ACt3rmp4ss|ADpassw0rd").
              and_return(response)
          )

          expect(action_message).to be_a Sip2::Responses::PatronInformation
          expect(action_message.raw_response).to eq response
        end
      end
    end

    def timestamp
      Time.now.strftime('%Y%m%d    %H%M%S')
    end
  end
end
