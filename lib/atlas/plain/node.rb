module Atlas
  module Plain
    class ValueNode < NullaryNode
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def to_plain
        value.to_s
      end
    end

    class ValuesNode < NAryNode
      def to_plain
        children.map(&:to_plain).join(', ')
      end
    end

    class ListNode < ValuesNode
      def to_plain
        "[#{super}]"
      end
    end

    class UnaryFunctionNode < UnaryNode
      def to_plain
        "#{self.class::FUNCTION}(#{child.to_plain})"
      end
    end

    class BinaryFunctionNode < BinaryNode
      def to_plain
        "#{self.class::FUNCTION}(#{children.first.to_plain}, #{children.second.to_plain})"
      end
    end

    class NAryFunctionNode < NAryNode
      def to_plain
        "#{self.class::FUNCTION}(#{children.map(&:to_plain).join(', ')})"
      end
    end

    {
      UnaryFunctionNode => %w(Exists),
      BinaryFunctionNode => %w(Eq NotEq Lt Lte Gt Gte),
      NAryFunctionNode => %w(And Or Includes Excludes),
    }.each do |klass, prefixes|
      prefixes.each do |prefix|
        class_def = Class.new(klass) do
          const_set(:FUNCTION, prefix.upcase.freeze)
        end

        const_set "#{prefix}Node", class_def
      end
    end
  end
end
