# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Responses::Status do
  let(:status) { described_class.new response }

  shared_examples 'when flag not set' do
    let(:response) { '98      23476520180508    2145442.00' }
    it { is_expected.to be false }
  end

  describe '#online?' do
    subject { status.online? }

    let(:response) { '98Y     23476520180508    2145442.00' }

    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#checkin_ok?' do
    subject { status.checkin_ok? }

    let(:response) { '98 Y    23476520180508    2145442.00' }

    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#checkout_ok?' do
    subject { status.checkout_ok? }

    let(:response) { '98  Y   23476520180508    2145442.00' }

    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#acs_renewal_policy?' do
    subject { status.acs_renewal_policy? }

    let(:response) { '98   Y  23476520180508    2145442.00' }

    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#status_update_ok?' do
    subject { status.status_update_ok? }

    let(:response) { '98    Y 23476520180508    2145442.00' }

    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#offline_ok?' do
    subject { status.offline_ok? }

    let(:response) { '98     Y23476520180508    2145442.00' }

    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#timeout_period' do
    subject { status.timeout_period }

    let(:response) { '98      23476520180508    2145442.00' }

    it { is_expected.to eq 234 }

    context 'when the timeout is not a number' do
      let(:response) { '98      ABC76520180508    2145442.00' }

      it { is_expected.to be_nil }
    end
  end

  describe '#retries_allowed' do
    subject { status.retries_allowed }

    let(:response) { '98      23476520180508    2145442.00' }

    it { is_expected.to eq 765 }

    context 'when the retries allowed is not a number' do
      let(:response) { '98      234ABC20180508    2145442.00' }

      it { is_expected.to be_nil }
    end
  end

  describe '#date_sync' do
    subject { status.date_sync }

    let(:response) { '98      23476520180508    2145442.00' }

    it { is_expected.to eq Time.new(2018, 5, 8, 21, 45, 44, '+00:00') }

    context 'when the response has an invalid id' do
      let(:response) { '97      23476520180508    2145442.00' }

      it { is_expected.to be_nil }
    end

    context 'when in a different timezone' do
      let(:response) { '98      23476520180508 CST2145442.00' }

      it { is_expected.to eq Time.new(2018, 5, 8, 21, 45, 44, '-06:00') }
    end
  end

  describe '#protocol_version' do
    subject { status.protocol_version }

    let(:response) { '98      23476520180508    2145442.00' }

    it { is_expected.to eq 2.0 }

    context 'when the protocol version is not a number' do
      let(:response) { '98      23476520180508    2145442.A0' }

      it { is_expected.to be_nil }
    end
  end

  describe '#institution_id' do
    subject { status.institution_id }

    let(:response) { 'FOO|AOMy institution|BAR' }

    it { is_expected.to eq 'My institution' }

    context 'when the institution id is blank' do
      let(:response) { 'FOO|AO|BAR' }

      it { is_expected.to eq '' }
    end

    context 'when the institution id is directly after the fixed component of the response' do
      let(:response) { '98YYYNYN99900320201123    1404002.00AOMy institution|AMSuper Library|etc' }

      it { is_expected.to eq 'My institution' }
    end

    context 'when there is not institution id' do
      let(:response) { 'FOO|BAR' }

      it { is_expected.to be_nil }
    end
  end

  describe '#library_name' do
    subject { status.library_name }

    let(:response) { 'FOO|AMSuper Library|BAR' }

    it { is_expected.to eq 'Super Library' }

    context 'when the library name is blank' do
      let(:response) { 'FOO|AM|BAR' }

      it { is_expected.to eq '' }
    end

    context 'when there is no library name variable' do
      let(:response) { 'FOO|BAR' }

      it { is_expected.to be_nil }
    end
  end

  describe '#supported_messages' do
    subject { status.supported_messages }

    let(:response) { 'FOO|BXNNNYNYYY|BAR' }

    it { is_expected.to eq %i[block_patron request_resend login patron_information] }

    context 'when the supported messages is blank' do
      let(:response) { 'FOO|BX|BAR' }

      it { is_expected.to eq [] }
    end

    context 'when there is no supported messages message' do
      let(:response) { 'FOO|BAR' }

      it { is_expected.to eq [] }
    end
  end

  describe '#terminal_location' do
    subject { status.terminal_location }

    let(:response) { 'FOO|ANFront door|BAR' }

    it { is_expected.to eq 'Front door' }

    context 'when the terminal location is blank' do
      let(:response) { 'FOO|AN|BAR' }

      it { is_expected.to eq '' }
    end

    context 'when there is no terminal location message' do
      let(:response) { 'FOO|BAR' }

      it { is_expected.to be_nil }
    end
  end

  describe '#screen_message' do
    subject { status.screen_message }

    let(:response) { 'FOO|AFMOON|BAR' }

    it { is_expected.to eq 'MOON' }

    context 'when the screen message is blank' do
      let(:response) { 'FOO|AF|BAR' }

      it { is_expected.to eq '' }
    end

    context 'when there is no screen message' do
      let(:response) { 'FOO|BAR' }

      it { is_expected.to be_nil }
    end
  end

  describe '#print_line' do
    subject { status.print_line }

    let(:response) { 'FOO|AGLogin please|BAR' }

    it { is_expected.to eq 'Login please' }

    context 'when the print line is blank' do
      let(:response) { 'FOO|AG|BAR' }

      it { is_expected.to eq '' }
    end

    context 'when there is no print line' do
      let(:response) { 'FOO|BAR' }

      it { is_expected.to be_nil }
    end
  end
end
