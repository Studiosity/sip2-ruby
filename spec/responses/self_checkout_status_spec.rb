require 'spec_helper'

describe Sip2::Responses::SelfCheckoutStatus do
  let(:self_checkout_status) { Sip2::Responses::SelfCheckoutStatus.new response }

  # rubocop:disable LineLength
  let(:response) { '98YYYYNN99999920101014    1158092.00AOMAIN|BXYYYNYYYYNNNNNYYN|AY0AZEDE3' }
  # rubocop:enable LineLength

  describe '#online_status?' do
    subject { self_checkout_status.online_status? }

    it { is_expected.to be true }
  end

  describe '#check_in_ok?' do
    subject { self_checkout_status.check_in_ok? }

    it { is_expected.to be true }
  end

  describe '#check_out_ok?' do
    subject { self_checkout_status.check_out_ok? }

    it { is_expected.to be true }
  end

  describe '#renewal_policy?' do
    subject { self_checkout_status.renewal_policy? }

    it { is_expected.to be true }
  end

  describe '#status_update_ok?' do
    subject { self_checkout_status.status_update_ok? }

    it { is_expected.to be false }
  end

  describe '#offline_ok?' do
    subject { self_checkout_status.offline_ok? }

    it { is_expected.to be false }
  end

  describe '#timeout_period' do
    subject { self_checkout_status.timeout_period }

    it { is_expected.to eq('999') }
  end

  describe '#retries_allowed' do
    subject { self_checkout_status.retries_allowed }

    it { is_expected.to eq('999') }
  end

  describe '#date_time_sync' do
    subject { self_checkout_status.date_time_sync }

    it { is_expected.to eq('20101014    115809') }
  end

  describe '#version' do
    subject { self_checkout_status.version }

    it { is_expected.to eq('2.00') }
  end

  describe '#institution_id' do
    subject { self_checkout_status.institution_id }

    it { is_expected.to eq('MAIN') }
  end

  describe '#library_name' do
    subject { self_checkout_status.library_name }

    it { is_expected.to eq(nil) }
  end

  describe '#supported_messages' do
    subject { self_checkout_status.supported_messages }

    it { is_expected.to eq('YYYNYYYYNNNNNYYN') }
  end

  describe '#screen_message' do
    subject { self_checkout_status.screen_message }

    it { is_expected.to eq(nil) }
  end

  describe '#print_line' do
    subject { self_checkout_status.print_line }

    it { is_expected.to eq(nil) }
  end
end
