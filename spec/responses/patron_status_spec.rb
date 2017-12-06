require 'spec_helper'

describe Sip2::Responses::PatronStatus do
  let(:patron_status) { Sip2::Responses::PatronStatus.new response }

  # rubocop:disable LineLength
  let(:raw_response_card_valid)                 { '24              00020101014    120240|BHGBP|BLY|CQY|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD' }
  let(:raw_response_card_expired)               { '24Y             00020101014    120240|BHGBP|BLY|CQY|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD' }
  let(:raw_response_card_renewal_denied)        { '24 Y            00020101014    120240|BHGBP|BLY|CQY|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD' }
  let(:raw_response_outstanding_fines)          { '24          Y   00020101014    120240|BHGBP|BLY|CQY|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD' }
  let(:raw_response_outstanding_fees)           { '24           Y  00020101014    120240|BHGBP|BLY|CQY|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD' }
  let(:invalid_response) { '' }
  # rubocop:enable LineLength

  describe '#charge_privileges_denied?' do
    subject { patron_status.charge_privileges_denied? }

    context 'with a valid card with no revoked privileges' do
      let(:response) { raw_response_card_valid }
      it { is_expected.to be false }
    end

    context 'with a card with revoked charge privileges' do
      let(:response) { raw_response_card_expired }
      it { is_expected.to be true }
    end

    context 'invalid response' do
      let(:response) { invalid_response }
      it { is_expected.to be false }
    end
  end

  describe '#renewal_privileges_denied?' do
    subject { patron_status.renewal_privileges_denied? }

    context 'with a valid card with no revoked privileges' do
      let(:response) { raw_response_card_valid }
      it { is_expected.to be false }
    end

    context 'with a card with revoked charge privileges' do
      let(:response) { raw_response_card_renewal_denied }
      it { is_expected.to be true }
    end

    context 'invalid response' do
      let(:response) { invalid_response }
      it { is_expected.to be false }
    end
  end

  describe 'excessive_fines_or_fees?' do
    subject { patron_status.excessive_fines_or_fees? }

    context 'with no outstanding fees or fines' do
      let(:response) { raw_response_card_valid }
      it { is_expected.to be false }
    end

    context 'with outstanding fees' do
      let(:response) { raw_response_outstanding_fees }
      it { is_expected.to be true }
    end

    context 'with outstanding fines' do
      let(:response) { raw_response_outstanding_fines }
      it { is_expected.to be true }
    end

    context 'invalid response' do
      let(:response) { invalid_response }
      it { is_expected.to be false }
    end
  end

  describe 'personal_name' do
    subject { patron_status.personal_name }

    let(:response) { raw_response_card_valid }
    it { is_expected.to eq 'Smith, John' }
  end

  describe 'valid_patron?' do
    subject { patron_status.valid_patron? }

    context 'when the card is valid' do
      let(:response) { raw_response_card_valid }
      it { is_expected.to be true }
    end

    context 'when the card number is invalid' do
      let(:response) { 'FOO|AQ|BAR' }
      it { is_expected.to be false }
    end
  end

  describe 'valid_patron_password?' do
    subject { patron_status.valid_patron_password? }

    context 'when the password is valid' do
      let(:response) { raw_response_card_valid }
      it { is_expected.to be true }
    end

    context 'when the password is invalid' do
      let(:response) { 'FOO|CQN|BAR' }
      it { is_expected.to be false }
    end
  end
end
