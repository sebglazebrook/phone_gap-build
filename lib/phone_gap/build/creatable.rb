module PhoneGap
  module Build
    module Creatable

      self.class_variable_set('@@creatable_attributes', {})
      self.class_variable_set('@@updatable_attributes', {})

      def self.included(base)
        base.extend(ClassMethods)
      end

      def creatable_attributes
        self.class.class_variable_get('@@creatable_attributes')[self.class]
      end

      def updatable_attributes
        self.class.class_variable_get('@@updatable_attributes')[self.class]
      end

      module ClassMethods

        def attr_creatable(*args)
          args.each { |attribute| add_to_collection('@@creatable_attributes', attribute) }
        end

        def attr_updatable(*args)
          args.each { |attribute| add_to_collection('@@updatable_attributes', attribute) }
        end

        def add_to_collection(collection_name, value)
          if self.class_variable_get(collection_name)[self]
            self.class_variable_get(collection_name)[self] << "@#{value}"
          else
            self.class_variable_get(collection_name)[self] = ["@#{value}"]
          end
        end
      end

    end
  end
end