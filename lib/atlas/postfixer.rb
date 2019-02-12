module Atlas
  class Postfixer
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens
    end

    def in_postfix
      @in_postfix ||= parse
    end

    private

    attr_reader :token, :operators, :values

    def parse
      @operators = []
      @values = []

      tokens.each do |token|
        @token = token
        step
      end

      values << pop_operator until operators.empty?
      values
    ensure
      @token = @operators = nil
    end

    def step
      case token
      when Atlas::OpeningGroupToken
        push_to_values
        push_to_operators
      when Atlas::ClosingGroupToken
        pop_grouped_operators
        push_to_values
      when Atlas::ComparisonToken, Atlas::LogicalToken
        pop_precedent_operators
        push_to_operators
      when Atlas::ValueToken, Atlas::ListToken
        push_to_values
      end
    end

    def push_to_operators
      operators << token
    end

    def push_to_values
      values << token
    end

    def top_operator
      operators.last
    end

    def pop_operator
      operators.pop
    end

    def pop_grouped_operators
      loop do
        operator = pop_operator
        break if operator.blank? || operator.is_a?(Atlas::OpeningGroupToken)
        values << operator
      end
    end

    def pop_precedent_operators
      current_precedence = precedence_of(token)
      while top_operator.present? && current_precedence < precedence_of(top_operator)
        values << pop_operator
      end
    end

    # :reek:UtilityFunction
    # :reek:ControlParameter
    def precedence_of(token)
      case token
      when Atlas::ComparisonToken then 4
      when Atlas::AndToken then 3
      when Atlas::OrToken then 2
      else 1
      end
    end
  end
end
