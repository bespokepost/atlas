module Atlas
  module Plain
    class Parser < Atlas::Parser
      def to_plain_query
        tree_root.to_plain
      end

      private

      def root_node
        ValuesNode.new
      end

      def node_from_token
        case token
        when Atlas::ValueToken then ValueNode.new(token.value)
        when Atlas::ClosingListToken then ListNode.new
        when Atlas::ExistsToken then ExistsNode.new
        when Atlas::AndToken then AndNode.new
        when Atlas::OrToken then OrNode.new
        when Atlas::EqToken then EqNode.new
        when Atlas::InToken then IncludesNode.new
        when Atlas::NotEqToken then NotEqNode.new
        when Atlas::LessThanToken then LtNode.new
        when Atlas::LessThanOrEqualToToken then LteNode.new
        when Atlas::GreaterThanToken then GtNode.new
        when Atlas::GreaterThanOrEqualToToken then GteNode.new
        end
      end
    end
  end
end
