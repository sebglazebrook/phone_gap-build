require 'phone_gap/build/version'
require 'phone_gap/build/credentials'
require 'phone_gap/build/app_factory'
require 'phone_gap/build/app'
require 'phone_gap/build/rest_resource'
require 'phone_gap/build/creatable'

require 'httparty'

module PhoneGap
  module Build

    def self.credentials(credentials)
      @credentials = Credentials.instance.set(credentials)
    end

    def self.apps
      http_response = HTTParty.get("https://build.phonegap.com/api/v1/apps?auth_token=#{@credentials.token}")
      parsed_response = JSON.parse(http_response.body)
      AppFactory.create_many(parsed_response)
    end

  end
end
