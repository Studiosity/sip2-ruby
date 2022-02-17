require 'spec_helper'

describe Sip2::Responses::BaseResponse do
  let(:response_object) { Sip2::Responses::BaseResponse.new raw_response }
  # rubocop:disable LineLength
  let(:raw_response) { '24 Y            00020101014    120240|BHGBP|BLY|CQN|AAJSMITH|AESmith, John|BV15.00|AY0AZE4FD' }
  # rubocop:enable LineLength

  context 'when given a blank raw_response' do
    let(:raw_response) { '   ' }

    it 'raises an ArgumentError' do
      expect { response_object }.to raise_error(described_class::EmptyResponseException)
    end
  end

  context 'when given a nil raw_response' do
    let(:raw_response) { nil }

    it 'raises an ArgumentError' do
      expect { response_object }.to raise_error(described_class::EmptyResponseException)
    end
  end

  describe '#text' do
    subject { response_object.send(:text, code) }

    context 'when the text exists in the response' do
      let(:code) { 'BH' }
      it 'returns the correct value' do
        expect(subject).to eq('GBP')
      end
    end

    context 'when the code is not found in the response' do
      let(:code) { 'ZZ' }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#boolean' do
    subject { response_object.send(:boolean, code) }

    context 'given a string code' do
      context 'when the value is Y' do
        let(:code) { 'BL' }
        it { is_expected.to be true }
      end
      context 'when the value is N' do
        let(:code) { 'CQ' }
        it { is_expected.to be false }
      end
      context 'when the string code is not found' do
        let(:code) { 'ZZ' }
        it { is_expected.to be false }
      end
    end

    context 'given a numeric code' do
      context 'when the value is blank' do
        let(:code) { 0 }
        it { is_expected.to be false }
      end
      context 'when the value is Y' do
        let(:code) { 1 }
        it { is_expected.to be true }
      end
    end
  end
end
