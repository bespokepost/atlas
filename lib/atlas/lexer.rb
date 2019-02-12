module Atlas
  # :reek:TooManyInstanceVariables
  class Lexer
    module Delimiters
      SPACES = /\s/
      COMMA = ','.freeze
      TERMINATOR = "\u0000".freeze
      END_OF_GROUP = Atlas::ClosingGroupToken::VALUE
      END_OF_LIST = Atlas::ClosingListToken::VALUE
    end

    class << self
      def terminate_string(input)
        output = input.dup
        output << Delimiters::TERMINATOR unless output.last == Delimiters::TERMINATOR
        output
      end

      %i(symbol_tokens word_tokens).each do |meth|
        token_class = Atlas.const_get(meth.to_s.classify)

        define_method meth do
          var = "@#{meth}"
          instance_variable_get(var) ||
            instance_variable_set(var, Atlas::SPECIAL_TOKEN_CLASSES.
              select { |klass| klass <= token_class }.
              map(&:new).map(&:freeze).index_by(&:value)).freeze
        end
      end
    end

    attr_reader :input, :buffer

    def initialize(input)
      @input = input
      @buffer = Buffer.new
      @quoting = false
    end

    def tokens
      @tokens ||= parse
    end

    private

    attr_reader :char, :peek

    def chars
      self.class.terminate_string(input).chars
    end

    def quoting?
      @quoting
    end

    def parse
      output = TokenList.new
      chars.each_cons(2) do |(char, peek)|
        @char = char
        @peek = peek

        token = parse_char

        if token.present?
          output << token
          buffer.reset
        end
      end
      output
    ensure
      @char = @peek = nil
    end

    def append
      @quoting = !@quoting if char == '"'
      buffer << char
    end

    def appendable?
      if quoting?
        true
      else
        case char
        when Delimiters::TERMINATOR,
             Delimiters::COMMA,
             Delimiters::SPACES
          false
        else
          true
        end
      end
    end

    def end_of_word?
      case peek
      when Delimiters::TERMINATOR
        true
      when Delimiters::END_OF_GROUP,
           Delimiters::END_OF_LIST,
           Delimiters::COMMA,
           Delimiters::SPACES
        !quoting?
      else
        false
      end
    end

    def parse_char
      append if appendable?

      if !buffer.empty?
        end_of_word? ? tokenize_buffer : tokenize_symbol
      end
    end

    def tokenize_symbol
      self.class.symbol_tokens[buffer.to_s]
    end

    def tokenize_word
      str = buffer.to_s
      self.class.word_tokens[str] || ValueToken.new(str)
    end

    def tokenize_buffer
      tokenize_symbol.presence || tokenize_word
    end
  end
end
