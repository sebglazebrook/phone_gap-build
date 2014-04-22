require 'phone_gap/build/creatable'
require 'phone_gap/build/base'

module PhoneGap
  module Build
    class RestResource < Base

      include PhoneGap::Build::Creatable
      attr_reader :id
      attr_accessor :poll_time_limit, :poll_interval
      attr_writer :errors

      def initialize(params = {})
        @poll_time_limit = 120
        @poll_interval = 5
        super(params)
      end

      def create
        response = ApiRequest.new.post(path, post_options)
        if response.success?
          populate_from_json(JSON.parse(response.body))
          self
        else
          update_errors(JSON.parse(response.body))
          false
        end
      end

      def update
        ApiRequest.new.put(path, query: {data: as_json(only: updatable_attributes)})
      end

      def save
        @id ? update : create
      end

      def destroy
        ApiRequest.new.delete(path)
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

      def errors
        @errors ||= []
      end

      private

      def post_options
        { query: { data: as_json(only: creatable_attributes) } }
      end

      def path
        @id ? "#{self.class.const_get('PATH')}/#{@id}" : "#{self.class.const_get('PATH')}"
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

      def update_errors(json)
        errors << json['error']
      end
    end
  end
end