module Atlas
  # The node children are meant to have a LIFO traversal
  class NodeChildren
    include Enumerable

    delegate :<<, :length, to: :elements

    def initialize
      @elements = []
    end

    def each(&blk)
      elements.reverse.each(&blk)
    end

    def first
      elements[-1]
    end

    def second
      elements[-2]
    end

    private

    attr_reader :elements
  end
end
