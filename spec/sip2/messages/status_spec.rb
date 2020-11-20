# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Messages::Status do
  subject(:status_message) { described_class.new(connection) }

  let(:connection) { instance_double 'Sip2::Connection' }

  describe '#action_message' do
    subject(:action_message) { status_message.action_message }

    let(:response) { '98      23476520180508    2145442.00AY1AZ1234' }

    it 'sends a well formed status message to the connection' do
      expect(connection).to(
        receive(:send_message).
          with('9909992.00').
          and_return(response)
      )

      expect(action_message).to be_a Sip2::Responses::Status
      expect(action_message.raw_response).to eq response
    end

    context 'when the connection doesnt return a message' do
      it 'returns nil' do
        expect(connection).to(
          receive(:send_message).
            with('9909992.00').
            and_return(nil)
        )

        expect(action_message).to be_nil
      end
    end

    context 'when the connection doesnt return the correct message type' do
      it 'returns nil' do
        expect(connection).to(
          receive(:send_message).
            with('9909992.00').
            and_return('97      23476520180508    2145442.00AY1AZ1234')
        )

        expect(action_message).to be_nil
      end
    end

    context 'status code is provided' do
      subject(:action_message) { status_message.action_message(status_code: status_code) }

      let(:status_code) { :out_of_paper }

      it 'sends a well formed status message to the connection' do
        expect(connection).to(
          receive(:send_message).
            with('9919992.00').
            and_return(response)
        )

        action_message
      end

      context 'when passing in the status code as a number' do
        let(:status_code) { 5 }

        it 'sends a well formed status message to the connection' do
          expect(connection).to(
            receive(:send_message).
              with('9959992.00').
              and_return(response)
          )

          action_message
        end
      end
    end

    context 'max print width is provided' do
      subject(:action_message) { status_message.action_message(max_print_width: 57) }

      it 'sends a well formed status message to the connection' do
        expect(connection).to(
          receive(:send_message).
            with('9900572.00').
            and_return(response)
        )

        action_message
      end
    end

    context 'protocol version is provided' do
      subject(:action_message) { status_message.action_message(protocol_version: 1.2) }

      it 'sends a well formed status message to the connection' do
        expect(connection).to(
          receive(:send_message).
            with('9909991.20').
            and_return(response)
        )

        action_message
      end
    end
  end
end
