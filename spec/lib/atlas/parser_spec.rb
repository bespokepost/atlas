require 'spec_helper'

describe Atlas::Parser do
  let(:parser) { described_class.new(token_list) }
  let(:token_list) { Atlas::TokenList.new(tokens) }
  let(:tokens) { [] }
end
