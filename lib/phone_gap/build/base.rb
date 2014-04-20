module PhoneGap
  module Build
    class Base

      def initialize(attributes = {})
        attributes.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

    end
  end
end