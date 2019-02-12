require 'spec_helper'

describe Atlas::NodeChildren do
  let(:children) { described_class.new }
  before { items.each { |item| children << item } }

  describe '#each' do
    let(:items) { %i(foo bar baz) }

    it 'yields in a LIFO order' do
      expect { |blk| children.each(&blk) }.to yield_successive_args(*items.reverse)
    end
  end

  describe '#first' do
    subject { children.first }
    let(:items) { %i(foo bar) }
    it { is_expected.to eq :bar }
  end

  describe '#second' do
    subject { children.second }
    let(:items) { %i(foo bar) }
    it { is_expected.to eq :foo }
  end
end
