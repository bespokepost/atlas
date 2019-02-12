require 'spec_helper'

describe Atlas::UnaryNode do
  let(:node) { described_class.new }

  it_behaves_like 'a node with parent methods'

  describe '#limit_reached?' do
    subject { node.limit_reached? }

    context 'without children' do
      it { is_expected.to eq false }
    end

    context 'with one child' do
      before { node << Atlas::NullaryNode.new }
      it { is_expected.to eq true }
    end
  end
end
