module Atlas
  class Buffer
    def initialize
      @io = StringIO.new
    end

    def empty?
      @io.length.zero?
    end

    def <<(input)
      @io << input
    end

    def to_s
      @io.string
    end

    def reset
      @io.reopen('')
    end
  end
end
