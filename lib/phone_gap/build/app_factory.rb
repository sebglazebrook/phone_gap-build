module PhoneGap
  module Build
    class AppFactory

      def self.create_many(attributes)
        attributes['apps'].map do |attrs|
          create(attrs)
        end
      end

      def self.create(attributes)
        App.new(attributes)
      end

    end
  end
end
