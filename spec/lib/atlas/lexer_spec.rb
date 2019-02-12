require 'spec_helper'

describe Atlas::Lexer do
  let(:lexer) { described_class.new(input) }

  describe '#tokens' do
    subject { lexer.tokens }

    context 'parentheses' do
      let(:input) { '(foobar)' }

      it do
        is_expected.
          to match_atlas_tokens(Atlas::OpeningGroupToken, Atlas::ValueToken.new('foobar'), Atlas::ClosingGroupToken)
      end
    end

    context 'logical' do
      describe 'AND' do
        let(:input) { 'foo AND bar' }

        it do
          is_expected.
            to match_atlas_tokens(Atlas::ValueToken.new('foo'), Atlas::AndToken, Atlas::ValueToken.new('bar'))
        end
      end

      describe 'OR' do
        let(:input) { 'foo OR bar' }

        it do
          is_expected.
            to match_atlas_tokens(Atlas::ValueToken.new('foo'), Atlas::OrToken, Atlas::ValueToken.new('bar'))
        end
      end
    end

    context 'comparison' do
      describe 'EQ' do
        let(:input) { 'foo EQ "bar"' }

        it do
          is_expected.
            to match_atlas_tokens(Atlas::ValueToken.new('foo'), Atlas::EqToken, Atlas::ValueToken.new('bar'))
        end
      end

      describe 'NOTEQ' do
        let(:input) { 'foo NOTEQ "bar"' }

        it do
          is_expected.
            to match_atlas_tokens(Atlas::ValueToken.new('foo'), Atlas::NotEqToken, Atlas::ValueToken.new('bar'))
        end
      end

      describe 'IN' do
        let(:input) { 'foo IN [bar, "baz"]' }

        it do
          is_expected.
            to match_atlas_tokens [
              Atlas::ValueToken.new('foo'),
              Atlas::InToken,
              Atlas::OpeningListToken,
              Atlas::ValueToken.new('bar'),
              Atlas::ValueToken.new('baz'),
              Atlas::ClosingListToken,
            ]
        end
      end

      describe 'LT' do
        let(:input) { 'radius LT 1.23' }

        it do
          is_expected.
            to match_atlas_tokens(Atlas::ValueToken.new('radius'), Atlas::LessThanToken, Atlas::ValueToken.new('1.23'))
        end
      end

      describe 'LTE' do
        let(:input) { 'radius LTE 1.23' }

        it do
          is_expected.
            to match_atlas_tokens [
              Atlas::ValueToken.new('radius'),
              Atlas::LessThanOrEqualToToken,
              Atlas::ValueToken.new('1.23'),
            ]
        end
      end

      describe 'GT' do
        let(:input) { 'age GT 21' }

        it do
          is_expected.
            to match_atlas_tokens(Atlas::ValueToken.new('age'), Atlas::GreaterThanToken, Atlas::ValueToken.new('21'))
        end
      end

      describe 'GTE' do
        let(:input) { 'age GTE 21' }

        it do
          is_expected.
            to match_atlas_tokens [
              Atlas::ValueToken.new('age'),
              Atlas::GreaterThanOrEqualToToken,
              Atlas::ValueToken.new('21'),
            ]
        end
      end

      describe 'EXISTS' do
        let(:input) { 'shipping_address EXISTS' }

        it do
          is_expected.to match_atlas_tokens(Atlas::ValueToken.new('shipping_address'), Atlas::ExistsToken)
        end
      end
    end

    context 'operator composition' do
      let(:input) do
        %(sparkAssigned NOTEQ 2018-12-01 AND
          toastReceived EQ true AND
          (
            birthday EXISTS OR
            birthday LT 1998-01-01
          ) AND
          country NOTEQ "CA" AND
          region NOTEQ "AZ")
      end

      it do
        is_expected.to match_atlas_tokens [
          Atlas::ValueToken.new('sparkAssigned'),
          Atlas::NotEqToken,
          Atlas::ValueToken.new('2018-12-01'),
          Atlas::AndToken,
          Atlas::ValueToken.new('toastReceived'),
          Atlas::EqToken,
          Atlas::ValueToken.new('true'),
          Atlas::AndToken,
          Atlas::OpeningGroupToken,
          Atlas::ValueToken.new('birthday'),
          Atlas::ExistsToken,
          Atlas::OrToken,
          Atlas::ValueToken.new('birthday'),
          Atlas::LessThanToken,
          Atlas::ValueToken.new('1998-01-01'),
          Atlas::ClosingGroupToken,
          Atlas::AndToken,
          Atlas::ValueToken.new('country'),
          Atlas::NotEqToken,
          Atlas::ValueToken.new('CA'),
          Atlas::AndToken,
          Atlas::ValueToken.new('region'),
          Atlas::NotEqToken,
          Atlas::ValueToken.new('AZ'),
        ]
      end
    end
  end
end
