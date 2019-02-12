module Atlas
  class TokenList < SimpleDelegator
    def initialize(tokens = [])
      @tokens = tokens
      super(@tokens)
    end

    def in_postfix
      Atlas::Postfixer.new(@tokens).in_postfix
    end
  end
end
