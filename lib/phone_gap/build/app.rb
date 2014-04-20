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
    end
  end
end
