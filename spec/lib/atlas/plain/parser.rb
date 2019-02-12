require 'spec_helper'
require 'atlas/plain'

describe Atlas::Plain::Parser do
  let(:parser) { described_class.new(token_list) }
  let(:token_list) { Atlas::TokenList.new(tokens) }

  describe '#to_plain_query' do
    subject { parser.to_plain_query }

    context 'grouping' do
      context 'implicit precedence' do
        let(:tokens) do
          [
            Atlas::ValueToken.new('foo'),
            Atlas::Lexer.word_tokens['EXISTS'],
            Atlas::Lexer.word_tokens['AND'],
            Atlas::ValueToken.new('bar'),
            Atlas::Lexer.word_tokens['EXISTS'],
            Atlas::Lexer.word_tokens['OR'],
            Atlas::ValueToken.new('baz'),
            Atlas::Lexer.word_tokens['EXISTS'],
          ]
        end

        it { is_expected.to eq 'OR(AND(EXISTS(foo), EXISTS(bar)), EXISTS(baz))' }
      end

      context 'explicit precedence' do
        let(:tokens) do
          [
            Atlas::ValueToken.new('foo'),
            Atlas::Lexer.word_tokens['EXISTS'],
            Atlas::Lexer.word_tokens['AND'],
            Atlas::Lexer.symbol_tokens['('],
            Atlas::ValueToken.new('bar'),
            Atlas::Lexer.word_tokens['EXISTS'],
            Atlas::Lexer.word_tokens['OR'],
            Atlas::ValueToken.new('baz'),
            Atlas::Lexer.word_tokens['EXISTS'],
            Atlas::Lexer.symbol_tokens[')'],
          ]
        end

        it { is_expected.to eq 'AND(EXISTS(foo), OR(EXISTS(bar), EXISTS(baz)))' }
      end
    end

    context 'logical expressions' do
      describe 'AND expression' do
        let(:tokens) do
          [
            Atlas::ValueToken.new('foo'),
            Atlas::Lexer.word_tokens['EXISTS'],
            Atlas::Lexer.word_tokens['AND'],
            Atlas::ValueToken.new('bar'),
            Atlas::Lexer.word_tokens['EQ'],
            Atlas::ValueToken.new('baz'),
          ]
        end

        it { is_expected.to eq 'AND(EXISTS(foo), EQ(bar, baz))' }
      end

      describe 'OR expression' do
        let(:tokens) do
          [
            Atlas::ValueToken.new('foo'),
            Atlas::Lexer.word_tokens['EQ'],
            Atlas::ValueToken.new('bar'),
            Atlas::Lexer.word_tokens['OR'],
            Atlas::ValueToken.new('baz'),
            Atlas::Lexer.word_tokens['EXISTS'],
          ]
        end

        it { is_expected.to eq 'OR(EQ(foo, bar), EXISTS(baz))' }
      end
    end

    context 'comparisons' do
      describe 'EQ' do
        let(:tokens) do
          [Atlas::ValueToken.new('name'), Atlas::Lexer.word_tokens['EQ'], Atlas::ValueToken.new('Jenkins')]
        end

        it { is_expected.to eq 'EQ(name, Jenkins)' }
      end

      describe 'NOTEQ' do
        let(:tokens) do
          [Atlas::ValueToken.new('name'), Atlas::Lexer.word_tokens['NOTEQ'], Atlas::ValueToken.new('Jenkins')]
        end

        it { is_expected.to eq 'NOTEQ(name, Jenkins)' }
      end

      describe 'IN' do
        let(:tokens) do
          [
            Atlas::ValueToken.new('color'),
            Atlas::Lexer.word_tokens['IN'],
            Atlas::Lexer.symbol_tokens['['],
            Atlas::ValueToken.new('red'),
            Atlas::ValueToken.new('blue'),
            Atlas::Lexer.symbol_tokens[']'],
          ]
        end

        it { is_expected.to eq 'INCLUDES(color, [red, blue])' }
      end

      %w(LT LTE GT GTE).each do |function|
        describe function do
          let(:tokens) do
            [Atlas::ValueToken.new('age'), Atlas::Lexer.word_tokens[function], Atlas::ValueToken.new('55')]
          end

          it { is_expected.to eq "#{function}(age, 55)" }
        end
      end

      describe 'EXISTS' do
        let(:tokens) { [Atlas::ValueToken.new('name'), Atlas::Lexer.word_tokens['EXISTS']] }
        it { is_expected.to eq 'EXISTS(name)' }
      end
    end
  end
end
