require 'phone_gap/build/creatable'
require 'httmultiparty'

module PhoneGap
  module Build
    class RestResource

      include PhoneGap::Build::Creatable
      include HTTMultiParty
      base_uri 'https://build.phonegap.com/api/v1'

      def initialize(attributes = {})
        attributes.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def create
        response = self.class.post(path, post_options)
        if response.success?
          populate_from_json(JSON.parse(response.body))
        end
        self
      end

      def update
        self.class.put(path, query: {data: as_json(only: updatable_attributes)})
      end

      def save
        @id ? update : create
      end

      def destroy
        self.class.delete(path)
      end

      def as_json(params = {})
        if params[:only]
          json = params[:only].inject({}) do | memo, attribute_name|
            memo[attribute_name[1..-1].to_sym] = instance_variable_get(attribute_name)
            memo
          end
        else
          json = {}
        end
        params[:remove_nils] ? json.delete_if {|k, v| v.nil? } : json
      end

      private

      def post_options
        { query: { data: as_json(only: creatable_attributes) } }
      end

      def path
        @id ? "#{self.class.const_get('PATH')}/#{@id}?auth_token=#{token}" : "#{self.class.const_get('PATH')}?auth_token=#{token}"
      end

      def token
        PhoneGap::Build::Credentials.instance.token
      end

      def populate_from_json(json)
        json.each do |key, value|
          if respond_to?("#{key}=")
            send("#{key}=", value)
          else
            instance_variable_set("@#{key}", value)
          end
        end
      end
    end
  end
end