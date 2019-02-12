require 'spec_helper'

describe Atlas::ValueNode do
  let(:value) { nil }
  let(:node) { described_class.new(value) }

  it_behaves_like 'a node with parent methods'

  describe '#value' do
    subject { node.value }
    let(:value) { 'foo' }
    it { is_expected.to eq value }
  end
end
