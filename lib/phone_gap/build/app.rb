require 'phone_gap/build/rest_resource'
require 'httmultiparty'

module PhoneGap
  module Build
    class App < RestResource

      PATH = '/apps'

      attr_accessor :title, :create_method, :package, :version, :description, :debug, :keys, :private,
                    :phonegap_version, :hydrates, :file

      attr_creatable :title, :create_method, :package, :version, :description, :debug, :keys, :private,
                     :phonegap_version, :hydrates, :file
      attr_updatable :title, :package, :version, :description, :debug, :private, :phonegap_version

      def post_options
        if file
          data_attributes = creatable_attributes
          data_attributes.delete('@file')
          {query: {file: file, data: as_json(only: data_attributes, remove_nils: true)}, detect_mime_type: true}
        else
          {query: {data: as_json(only: creatable_attributes, remove_nils: true)}}
        end
      end

      def build
        ApiRequest.new.post("#{PATH}/#{id}/build")
      end

      def build_complete?(params = {})
        complete = false
        error = false
        start_time = Time.now
        time_limit = start_time + (params[:poll_time_limit] || poll_time_limit)
        while !complete && (Time.now < time_limit) && !error
          response = ApiRequest.new.get("#{PATH}/#{id}")
          if response.success?
            json_object = JSON.parse(response.body)
            complete = json_object['status'].all? { |platform, status| status == 'complete' }
            error = json_object['status'].any? { |platform, status| status == 'error' }
          end
          sleep (params[:poll_interval] || poll_interval) unless complete or error
        end
        raise BuildError.new('An error occurred building at least one of the apps.') if error
        complete
      end
    end

    class BuildError < Exception ; end
  end
end