require 'spec_helper'

describe Atlas::Buffer do
  let(:buffer) { described_class.new }

  describe '#empty?' do
    subject { buffer.empty? }

    context 'when empty' do
      it { is_expected.to eq true }
    end

    context 'when not empty' do
      before { buffer << 'content' }
      it { is_expected.to eq false }
    end
  end

  describe '#<<' do
    let(:input) { 'some content' }
    subject { buffer << input }

    it 'adds the content' do
      expect { subject }.to(change { buffer.to_s }.to(input))
    end
  end

  describe '#to_s' do
    let(:input) { 'some content' }
    before { buffer << input }
    subject { buffer.to_s }
    it { is_expected.to eq input }
  end

  describe '#reset' do
    before { buffer << 'content' }
    subject { buffer.reset }

    it 'clears the content' do
      expect { subject }.to(change { buffer.to_s }.to(''))
    end
  end
end
