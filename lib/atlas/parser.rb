module Atlas
  # :reek:TooManyInstanceVariables
  class Parser
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.in_postfix
    end

    private

    attr_reader :current_tokens, :current_node, :group_stack, :token

    def tree_root
      @tree_root ||= parse_tree_root
    end

    def parse_tree_root
      root_node.tap do |root|
        @current_node = root
        @current_tokens = tokens.dup
        @group_stack = []
        parse_tokens
      end
    ensure
      @current_node = @current_tokens = @group_stack = nil
    end

    def parse_tokens
      until current_tokens.empty?
        @token = pop
        parse_token
      end
    ensure
      @token = nil
    end

    def pop
      current_tokens.pop
    end

    def parse_token
      case token
      when Atlas::ClosingGroupToken
        group_stack << current_node
      when Atlas::OpeningGroupToken
        @current_node = group_stack.pop
      when Atlas::OpeningListToken
        set_current_node_to_ancestor
      else
        process_child_node
      end
    end

    def process_child_node
      node = node_from_token
      if node.present?
        current_node << node

        if current_node.limit_reached?
          set_current_node_to_ancestor
        elsif !node.limit_reached?
          @current_node = node
        end
      end

      def set_current_node_to_ancestor
        loop do
          @current_node = current_node.parent

          # If the parent is also full, keep going up the ancestry
          break unless @current_node.limit_reached?
        end
      end
    end

    def node_from_token; end
  end
end
