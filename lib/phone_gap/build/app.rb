require 'phone_gap/build/rest_resource'
require 'httmultiparty'

module PhoneGap
  module Build
    class App < RestResource

      PATH = '/apps'

      attr_accessor :title, :create_method, :package, :version, :description, :debug, :keys, :private,
                    :phonegap_version, :hydrates, :file, :status

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

      # @TODO fix this ugly method!
      def build_complete?(params = {})
        complete = false
        error = false
        start_time = Time.now
        time_limit = start_time + (params[:poll_time_limit] || poll_time_limit)
        while !complete && (Time.now < time_limit) && !error
          response = ApiRequest.new.get("#{PATH}/#{id}")
          if response.success?
            json_object = JSON.parse(response.body)
            complete = json_object['status'].all? { |platform, status| %w(complete skip).include?(status) }
            error = json_object['status'].any? { |platform, status| status == 'error' }
          end
          sleep (params[:poll_interval] || poll_interval) unless complete or error
        end
        raise BuildError.new('An error occurred building at least one of the apps.') if error
        raise BuildError.new('Builds did not complete within the allotted time.') if !error && !complete
        populate_from_json(json_object)
        complete
      end

      #@TODO another hacky method. Come on Seb :-)
      def download(params = {})
        platforms_to_download = params[:platforms] ? params[:platforms] : built_platforms
        platforms_to_download.each do |platform|
          response =  ApiRequest.new.get("#{PATH}/#{id}/#{platform}")
          if response.success?
            file_name = file_name_from_uri(response.request.instance_variable_get(:@last_uri).request_uri)
            dir = File.join((params[:save_to] ? params[:save_to] : '/tmp'), platform.to_s)
            file_path =  File.join(dir, file_name)
            FileUtils.mkdir_p(dir)
            puts "Saving to #{file_path}"
            File.open(file_path, 'w+') { |f| f.write(response.body) }
            puts 'Download complete'
          end
        end
      end

      private

      def built_platforms
        status.delete_if { |package, build_status| build_status != 'complete' }.keys
      end

      def file_name_from_uri(uri)
        uri.match(/\/([^\/]*)$/)[0]
      end
    end

    class BuildError < Exception ; end
  end
end