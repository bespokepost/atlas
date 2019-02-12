shared_examples 'a node with parent methods' do
  describe '#parent' do
    subject { node.parent }

    context 'without a parent' do
      it { is_expected.to be_nil }
    end

    context 'with a parent' do
      let(:parent_node) { Atlas::UnaryNode.new }
      before { parent_node << node }
      it { is_expected.to eq parent_node }
    end
  end
end
