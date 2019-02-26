module Atlas
  class Token; end

  class ValueToken < Token
    def self.clean_input(input)
      input.to_s.strip.gsub(/^"(.*)"$/, '\1')
    end

    attr_reader :value

    def initialize(value)
      @value = self.class.clean_input(value)
    end
  end

  class SymbolToken < Token; end
  class GroupingToken < SymbolToken; end
  class ListToken < SymbolToken; end

  class WordToken < Token; end
  class LogicalToken < WordToken; end
  class ComparisonToken < WordToken; end

  SPECIAL_TOKEN_CLASSES = [
    ['(', 'OpeningGroupToken', GroupingToken],
    [')', 'ClosingGroupToken', GroupingToken],
    ['[', 'OpeningListToken', ListToken],
    [']', 'ClosingListToken', ListToken],
    ['AND', 'AndToken', LogicalToken],
    ['OR', 'OrToken', LogicalToken],
    ['EQ', 'EqToken', ComparisonToken],
    ['NOTEQ', 'NotEqToken', ComparisonToken],
    ['IN', 'InToken', ComparisonToken],
    ['LT', 'LessThanToken', ComparisonToken],
    ['LTE', 'LessThanOrEqualToToken', ComparisonToken],
    ['GT', 'GreaterThanToken', ComparisonToken],
    ['GTE', 'GreaterThanOrEqualToToken', ComparisonToken],
    ['EXISTS', 'ExistsToken', ComparisonToken],
    ['NOTEXISTS', 'NotExistsToken', ComparisonToken],
  ].map do |(character, class_name, superclass)|
    klass = Class.new(superclass) do
      const_set :VALUE, character.freeze

      def value
        self.class::VALUE
      end
    end

    Atlas.const_set(class_name, klass)

    klass
  end
end
