require 'spec_helper'

describe Sip2::Responses::PatronInformation do
  let(:patron_information) { Sip2::Responses::PatronInformation.new response }

  # rubocop:disable LineLength
  let(:raw_response_valid_patron) { '64              00020101014    120549000000000003        0002AOMAIN|AAJSMITH|AESmith, John|BLY|CQY|AU111111|BEbob@example.com|AQMOON|AY0AZE0E8' }
  let(:raw_response_invalid_patron) { '64              00020101014    120549000000000003        0002AOMAIN|AAJSMITH|AESmith, John|BLN|AU111111|AY0AZE0E8' }
  let(:raw_response_incorrect_barcode) { '64              00020101014    120549000000000003        0002AOMAIN|AAJSMITH|AESmith, John|BLY|CQN|AU111111|AY0AZE0E8' }
  let(:invalid_response) { '' }
  # rubocop:enable LineLength

  describe '#patron_valid?' do
    subject { patron_information.patron_valid? }

    let(:response) { raw_response_valid_patron }
    it { is_expected.to be_truthy }

    context 'false response' do
      let(:response) { raw_response_invalid_patron }
      it { is_expected.to be_falsey }
    end
  end

  describe 'authenticated?' do
    subject { patron_information.authenticated? }

    let(:response) { raw_response_valid_patron }
    it { is_expected.to be_truthy }

    context 'false response' do
      let(:response) { raw_response_incorrect_barcode }
      it { is_expected.to be_falsey }
    end
  end

  describe 'email' do
    subject { patron_information.email }

    let(:response) { raw_response_valid_patron }
    it { is_expected.to eq 'bob@example.com' }

    context 'blank response' do
      let(:response) { 'FOO|BE|BAR' }
      it { is_expected.to eq '' }
    end

    context 'invalid response' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end

  describe 'location' do
    subject { patron_information.location }

    let(:response) { raw_response_valid_patron }
    it { is_expected.to eq 'MOON' }

    context 'blank response' do
      let(:response) { 'FOO|AQ|BAR' }
      it { is_expected.to eq '' }
    end
  end
end
