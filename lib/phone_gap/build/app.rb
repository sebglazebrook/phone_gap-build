require 'phone_gap/build/rest_resource'
require 'httmultiparty'

module PhoneGap
  module Build
    class App < RestResource

      attr_accessor :title, :create_method, :package, :version, :description, :debug, :keys, :private,
                    :phonegap_version, :hydrates

      PATH = '/apps'
      attr_creatable :title, :create_method, :package, :version, :description, :debug, :keys, :private, :phonegap_version, :hydrates
      attr_updatable :title, :package, :version, :description, :debug, :private, :phonegap_version


    end
  end
end
