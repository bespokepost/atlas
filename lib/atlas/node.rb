module Atlas
  class Node
    attr_reader :parent

    def limit_reached?
      true
    end

    protected

    attr_writer :parent
  end

  private_constant :Node

  class ArityNode < Node
    class ArityLimitError < ::StandardError; end

    attr_reader :children

    def initialize(initial_children = [])
      @children = NodeChildren.new
      initial_children.each { |child| append(child) }
    end

    def limit
      self.class::LIMIT
    end

    def <<(child)
      if limit_reached?
        raise ArityLimitError, "Number of children limit reached (#{limit})"
      else
        append(child)
      end

      self
    end

    def limit_reached?
      children.length >= limit
    end

    private

    def append(child)
      child.parent = self
      children << child
    end
  end

  private_constant :ArityNode

  class NullaryNode < ArityNode
    LIMIT = 0

    def limit_reached?
      true
    end
  end

  class UnaryNode < ArityNode
    LIMIT = 1

    def child
      children.first
    end
  end

  class BinaryNode < ArityNode
    LIMIT = 2

    delegate :first, :second, to: :children
  end

  class NAryNode < ArityNode
    LIMIT = nil

    def limit_reached?
      false
    end
  end

  class ValueNode < NullaryNode
    attr_reader :value

    def initialize(value = nil)
      @value = value
    end
  end

  class ValuesNode < NAryNode; end
end
