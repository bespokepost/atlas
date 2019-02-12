require 'spec_helper'

describe Atlas::NullaryNode do
  let(:node) { described_class.new }

  it_behaves_like 'a node with parent methods'

  describe '#limit_reached?' do
    subject { node.limit_reached? }
    it { is_expected.to eq true }
  end
end
