require 'spec_helper'

describe Sip2::Responses::PatronInformation do
  let(:patron_information) { Sip2::Responses::PatronInformation.new response }

  # rubocop:disable LineLength
  let(:raw_response_valid_patron) { '64              00020101014    120549000000000003        0002AOMAIN|AAJSMITH|AESmith, John|BLY|CQY|AU111111|BEbob@example.com|AQMOON|AY0AZE0E8' }
  let(:raw_response_invalid_patron) { '64              00020101014    120549000000000003        0002AOMAIN|AAJSMITH|AESmith, John|BLN|AU111111|AY0AZE0E8' }
  let(:raw_response_incorrect_barcode) { '64              00020101014    120549000000000003        0002AOMAIN|AAJSMITH|AESmith, John|BLY|CQN|AU111111|AY0AZE0E8' }
  let(:invalid_response) { '' }
  let(:response_with_pt_field) do
    %[64              00120230601    111226000000000008000100000000AODoylestown|AAD1111111|AETest,Account|BLY|CQY|BHUSD|BV0.50|CC19.50|AKL9158574 The pie an 06/05/2023|AKL9716975 Cook's ill 06/21/2023|AKL1288933 The perfec 06/21/2023|AKL9585820 The rye ba 06/21/2023|AKL1245165 Half baked 06/21/2023|AKL6588364 The savory 06/21/2023|AKL1115080 Pasta Gran 06/21/2023|AKL1288987 Milk Stree 06/21/2023|AV 592770 $0.50 "Overdue book materia" Chirri & Chirra|FB0.50|PEI380|PT2020|AY8AZ821F]
  end
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

  describe 'custom_field' do
    subject{ patron_information.custom_field('PT') }

    let(:response) { response_with_pt_field }
    it { is_expected.to eq('2020') }

    context 'given a response without the custom field' do
      let(:response) { raw_response_valid_patron }
      it { is_expected.to be_nil}
    end
  end
end
