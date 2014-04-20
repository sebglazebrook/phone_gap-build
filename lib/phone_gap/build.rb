require 'phone_gap/build/version'
require 'phone_gap/build/base'
require 'phone_gap/build/credentials'
require 'phone_gap/build/app_factory'
require 'phone_gap/build/app'
require 'phone_gap/build/api_request'
require 'phone_gap/build/rest_resource'
require 'phone_gap/build/creatable'
require 'phone_gap/build/error'

require 'httparty'

module PhoneGap
  module Build

    def self.credentials(credentials)
      @credentials = Credentials.instance.set(credentials)
    end

    def self.apps
      if credentials?
        http_response = HTTParty.get("https://build.phonegap.com/api/v1/apps?auth_token=#{@credentials.token}")
        parsed_response = JSON.parse(http_response.body)
        AppFactory.create_many(parsed_response)
      else
        Error.new(message: 'Api credentials not found. Set them or add thmem to config/phonegap.yml')
      end
    end

    def self.credentials?
      if @credentials && @credentials.token
        true
      else
        Credentials.instance.load
      end
    end
  end
end
