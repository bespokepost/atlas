require 'spec_helper'

describe Atlas::NAryNode do
  let(:node) { described_class.new }

  it_behaves_like 'a node with parent methods'

  describe '#limit_reached?' do
    subject { node.limit_reached? }

    context 'without children' do
      it { is_expected.to eq false }
    end

    context 'with children' do
      before { node << Atlas::NullaryNode.new }
      it { is_expected.to eq false }
    end
  end
end
