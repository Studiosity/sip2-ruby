# frozen_string_literal: true

require 'spec_helper'

describe Sip2::Responses::PatronInformation do
  let(:patron_information) { Sip2::Responses::PatronInformation.new response }

  shared_examples 'when flag not set' do
    let(:response) { '64              00020180508    21454400000' }
    it { is_expected.to be false }
  end

  describe '#charge_privileges_denied?' do
    subject { patron_information.charge_privileges_denied? }

    let(:response) { '64Y             00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#renewal_privileges_denied?' do
    subject { patron_information.renewal_privileges_denied? }

    let(:response) { '64 Y            00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#recall_privileges_denied?' do
    subject { patron_information.recall_privileges_denied? }

    let(:response) { '64  Y           00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#hold_privileges_denied?' do
    subject { patron_information.hold_privileges_denied? }

    let(:response) { '64   Y          00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#card_reported_lost?' do
    subject { patron_information.card_reported_lost? }

    let(:response) { '64    Y         00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#too_many_items_charged?' do
    subject { patron_information.too_many_items_charged? }

    let(:response) { '64     Y        00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#too_many_items_overdue?' do
    subject { patron_information.too_many_items_overdue? }

    let(:response) { '64      Y       00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#too_many_renewals?' do
    subject { patron_information.too_many_renewals? }

    let(:response) { '64       Y      00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#too_many_claims_of_items_returned?' do
    subject { patron_information.too_many_claims_of_items_returned? }

    let(:response) { '64        Y     00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#too_many_items_lost?' do
    subject { patron_information.too_many_items_lost? }

    let(:response) { '64         Y    00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#excessive_outstanding_fines?' do
    subject { patron_information.excessive_outstanding_fines? }

    let(:response) { '64          Y   00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#excessive_outstanding_fees?' do
    subject { patron_information.excessive_outstanding_fees? }

    let(:response) { '64           Y  00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#recall_overdue?' do
    subject { patron_information.recall_overdue? }

    let(:response) { '64            Y 00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#too_many_items_billed?' do
    subject { patron_information.too_many_items_billed? }

    let(:response) { '64             Y00020180508    21454400000' }
    it { is_expected.to be true }

    it_behaves_like 'when flag not set'
  end

  describe '#language' do
    subject { patron_information.language }

    let(:response) { '64              00020180508    21454400000' }
    it { is_expected.to eq 'Unknown' }

    context 'language code `012`' do
      let(:response) { '64              01220180508    21454400000' }
      it { is_expected.to eq 'Norwegian' }
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

  describe '#authenticated?' do
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

  describe '#email' do
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

  describe '#location' do
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

  describe '#screen_message' do
    subject { patron_information.screen_message }

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
end
