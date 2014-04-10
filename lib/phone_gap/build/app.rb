module PhoneGap
  module Build
    class App

      def initialize(params)
        params.each do |key, value|
          instance_variable_set("@#{key}", value)
          singleton_class.class_eval { attr_accessor key }
        end
      end
    end

  end
end
