require 'spec_helper'

describe Atlas::Postfixer do
  let(:postfixer) { described_class.new(tokens) }

  describe '#in_postfix' do
    subject { postfixer.in_postfix }

    context 'parentheses' do
      let(:tokens) do
        # foo EXISTS AND (bar EXISTS OR baz EXISTS)
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

      it do
        is_expected.to match_atlas_tokens [
          Atlas::ValueToken.new('foo'),
          Atlas::Lexer.word_tokens['EXISTS'],
          Atlas::Lexer.symbol_tokens['('],
          Atlas::ValueToken.new('bar'),
          Atlas::Lexer.word_tokens['EXISTS'],
          Atlas::ValueToken.new('baz'),
          Atlas::Lexer.word_tokens['EXISTS'],
          Atlas::Lexer.word_tokens['OR'],
          Atlas::Lexer.symbol_tokens[')'],
          Atlas::Lexer.word_tokens['AND'],
        ]
      end
    end

    context 'logical' do
      %w(AND OR).each do |operator|
        describe operator do
          let(:tokens) do
            [
              Atlas::ValueToken.new('foo'),
              Atlas::Lexer.word_tokens['EXISTS'],
              Atlas::Lexer.word_tokens[operator],
              Atlas::ValueToken.new('bar'),
              Atlas::Lexer.word_tokens['EXISTS'],
            ]
          end

          it do
            is_expected.to match_atlas_tokens [
              Atlas::ValueToken.new('foo'),
              Atlas::Lexer.word_tokens['EXISTS'],
              Atlas::ValueToken.new('bar'),
              Atlas::Lexer.word_tokens['EXISTS'],
              Atlas::Lexer.word_tokens[operator],
            ]
          end
        end
      end
    end

    context 'comparison' do
      %w(EQ NOTEQ).each do |operator|
        describe operator do
          let(:tokens) do
            [
              Atlas::ValueToken.new('foo'),
              Atlas::Lexer.word_tokens[operator],
              Atlas::ValueToken.new('bar'),
            ]
          end

          it do
            is_expected.to match_atlas_tokens [
              Atlas::ValueToken.new('foo'),
              Atlas::ValueToken.new('bar'),
              Atlas::Lexer.word_tokens[operator],
            ]
          end
        end
      end

      describe 'IN' do
        let(:tokens) do
          [
            Atlas::ValueToken.new('name'),
            Atlas::Lexer.word_tokens['IN'],
            Atlas::Lexer.symbol_tokens['['],
            Atlas::ValueToken.new('foo'),
            Atlas::ValueToken.new('bar'),
            Atlas::ValueToken.new('baz'),
            Atlas::Lexer.symbol_tokens[']'],
          ]
        end

        it do
          is_expected.to match_atlas_tokens [
            Atlas::ValueToken.new('name'),
            Atlas::Lexer.symbol_tokens['['],
            Atlas::ValueToken.new('foo'),
            Atlas::ValueToken.new('bar'),
            Atlas::ValueToken.new('baz'),
            Atlas::Lexer.symbol_tokens[']'],
            Atlas::Lexer.word_tokens['IN'],
          ]
        end
      end

      %w(LT LTE GT GTE).each do |operator|
        describe operator do
          let(:tokens) do
            [
              Atlas::ValueToken.new('age'),
              Atlas::Lexer.word_tokens[operator],
              Atlas::ValueToken.new('21'),
            ]
          end

          it do
            is_expected.to match_atlas_tokens [
              Atlas::ValueToken.new('age'),
              Atlas::ValueToken.new('21'),
              Atlas::Lexer.word_tokens[operator],
            ]
          end
        end
      end

      describe 'EXISTS' do
        let(:tokens) { [Atlas::ValueToken.new('foo'), Atlas::Lexer.word_tokens['EXISTS']] }
        it { is_expected.to match_atlas_tokens(Atlas::ValueToken.new('foo'), Atlas::Lexer.word_tokens['EXISTS']) }
      end
    end
  end
end
