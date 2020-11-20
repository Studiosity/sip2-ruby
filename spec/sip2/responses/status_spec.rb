# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Responses::Status do
  let(:status) { Sip2::Responses::Status.new response }

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
    it { is_expected.to eq '234' }
  end

  describe '#retries_allowed' do
    subject { status.retries_allowed }

    let(:response) { '98      23476520180508    2145442.00' }
    it { is_expected.to eq '765' }
  end

  describe '#date_sync' do
    subject { status.date_sync }

    let(:response) { '98      23476520180508    2145442.00' }
    it { is_expected.to eq Time.new(2018, 5, 8, 21, 45, 44, '+00:00') }

    context 'bad response' do
      let(:response) { '97      23476520180508    2145442.00' }
      it { is_expected.to be_nil }
    end

    context 'different timezone' do
      let(:response) { '98      23476520180508 CST2145442.00' }
      it { is_expected.to eq Time.new(2018, 5, 8, 21, 45, 44, '-06:00') }
    end
  end

  describe '#protocol_version' do
    subject { status.protocol_version }

    let(:response) { '98      23476520180508    2145442.00' }
    it { is_expected.to eq '2.00' }
  end

  describe '#institution_id' do
    subject { status.institution_id }

    let(:response) { 'FOO|AOMy institution|BAR' }
    it { is_expected.to eq 'My institution' }

    context 'blank response' do
      let(:response) { 'FOO|AO|BAR' }
      it { is_expected.to eq '' }
    end

    context 'invalid response' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end

  describe '#library_name' do
    subject { status.library_name }

    let(:response) { 'FOO|AMSuper Library|BAR' }
    it { is_expected.to eq 'Super Library' }

    context 'blank response' do
      let(:response) { 'FOO|AM|BAR' }
      it { is_expected.to eq '' }
    end

    context 'no library name variable' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end

  describe '#supported_messages' do
    subject { status.supported_messages }

    let(:response) { 'FOO|BXNNNYNYYY|BAR' }
    it { is_expected.to eq %i[block_patron request_resend login patron_information] }

    context 'blank response' do
      let(:response) { 'FOO|BX|BAR' }
      it { is_expected.to eq [] }
    end

    context 'no supported messages message' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to eq [] }
    end
  end

  describe '#terminal_location' do
    subject { status.terminal_location }

    let(:response) { 'FOO|ANFront door|BAR' }
    it { is_expected.to eq 'Front door' }

    context 'blank response' do
      let(:response) { 'FOO|AN|BAR' }
      it { is_expected.to eq '' }
    end

    context 'no terminal location message' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end

  describe '#screen_message' do
    subject { status.screen_message }

    let(:response) { 'FOO|AFMOON|BAR' }
    it { is_expected.to eq 'MOON' }

    context 'blank response' do
      let(:response) { 'FOO|AF|BAR' }
      it { is_expected.to eq '' }
    end

    context 'no screen message' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end

  describe '#print_line' do
    subject { status.print_line }

    let(:response) { 'FOO|AGLogin please|BAR' }
    it { is_expected.to eq 'Login please' }

    context 'blank response' do
      let(:response) { 'FOO|AG|BAR' }
      it { is_expected.to eq '' }
    end

    context 'no screen message' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end
end
