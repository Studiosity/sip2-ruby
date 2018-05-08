require 'spec_helper'

describe Sip2::PatronInformation do
  let(:patron_information) { Sip2::PatronInformation.new response }

  describe '#patron_status' do
    subject { patron_information.patron_status }

    let(:response) { '64       Not Bad00020180508    21454400000' }
    it { is_expected.to eq 'Not Bad' }

    context 'bad response' do
      let(:response) { '63       Not Bad00020180508    21454400000' }
      it { is_expected.to be_nil }
    end
  end

  describe '#language_code' do
    subject { patron_information.language_code }

    let(:response) { '64       Not Bad00020180508    21454400000' }
    it { is_expected.to eq '000' }

    context 'bad response' do
      let(:response) { '63       Not Bad00020180508    21454400000' }
      it { is_expected.to be_nil }
    end
  end

  describe '#transaction_date' do
    subject { patron_information.transaction_date }

    let(:response) { '64       Not Bad00020180508    21454400000' }
    it { is_expected.to eq Time.new(2018, 5, 8, 21, 45, 44, '+00:00') }

    context 'bad response' do
      let(:response) { '63       Not Bad00020180508    21454400000' }
      it { is_expected.to be_nil }
    end

    context 'different timezone' do
      let(:response) { '64       Not Bad00020180508 CST21454400000' }
      it { is_expected.to eq Time.new(2018, 5, 8, 21, 45, 44, '-06:00') }
    end
  end

  describe '#patron_valid?' do
    subject { patron_information.patron_valid? }

    let(:response) { 'FOO|BLY|BAR' }
    it { is_expected.to be_truthy }

    context 'false response' do
      let(:response) { 'FOO|BLN|BAR' }
      it { is_expected.to be_falsey }
    end

    context 'invalid response' do
      let(:response) { 'FOO|BL|BAR' }
      it { is_expected.to be_falsey }
    end
  end

  describe 'authenticated?' do
    subject { patron_information.authenticated? }

    let(:response) { 'FOO|CQY|BAR' }
    it { is_expected.to be_truthy }

    context 'false response' do
      let(:response) { 'FOO|CQN|BAR' }
      it { is_expected.to be_falsey }
    end

    context 'invalid response' do
      let(:response) { 'FOO|CQ|BAR' }
      it { is_expected.to be_falsey }
    end
  end

  describe 'email' do
    subject { patron_information.email }

    let(:response) { 'FOO|BEbob@example.com|BAR' }
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

    let(:response) { 'FOO|AQMOON|BAR' }
    it { is_expected.to eq 'MOON' }

    context 'blank response' do
      let(:response) { 'FOO|AQ|BAR' }
      it { is_expected.to eq '' }
    end

    context 'no location information' do
      let(:response) { 'FOO|BAR' }
      it { is_expected.to be_nil }
    end
  end
end
