module Atlas
  module Testing
    module RspecMatchers
      extend RSpec::Matchers::DSL

      # :reek:UtilityFunction
      def match_token?(expected, actual)
        actual_class = actual.class

        if expected.is_a?(Class)
          expected == actual_class
        else
          expected.class == actual_class && expected.value == actual.value
        end
      end

      # :reek:UtilityFunction
      def class_name(klass)
        klass.to_s.gsub(/Atlas::(.*)Token/, '\1')
      end

      # :reek:UtilityFunction
      # :reek:FeatureEnvy
      def to_string(input)
        if input.is_a?(Class)
          "#<#{class_name(input)}>"
        elsif input.present?
          "#<#{class_name(input.class)} #{input.value}>"
        else
          input.to_s
        end
      end

      def failure_message_for_lists(expecteds, actuals)
        expecteds = expecteds.flatten
        expecteds_list = expecteds.map { |expected| to_string(expected) }.join(', ')
        actuals_list = actuals.map { |actual| to_string(actual) }.join(', ')
        diff = expecteds.zip(actuals).each_with_index.
          reject { |(expected, actual), _| match_token?(expected, actual) }.
          map { |(expected, actual), idx| "%4d %32s does not match %s" % [idx, to_string(actual), to_string(expected)] }

        "expected [#{actuals_list}] to match Atlas tokens [#{expecteds_list}]\n\n#{diff.join("\n")}"
      end

      RSpec::Matchers.define :match_atlas_token do |expected|
        match do |actual|
          match_token?(expected, actual)
        end

        failure_message do |actual|
          "expected #{to_string(actual)} to match Atlas token #{to_string(expected)}"
        end
      end

      RSpec::Matchers.define :match_atlas_tokens do |*expecteds|
        match do |actuals|
          expecteds.flatten.zip(actuals).all? do |(expected, actual)|
            match_token?(expected, actual)
          end
        end

        failure_message do |actuals|
          failure_message_for_lists(expecteds, actuals)
        end
      end
    end
  end
end
