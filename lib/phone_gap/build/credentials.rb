require 'singleton'

module PhoneGap
  module Build
    class Credentials

      include Singleton

      attr_reader :username, :password, :token, :config
      attr_writer :token

      def set(credentials)
        @username = credentials[:username]
        @password = credentials[:password]
        @token = credentials[:token]
        self
      end

      def load
        config_file = File.expand_path('../../../../config/phonegap.yml', __FILE__)
        if File.exists? config_file
          @config = YAML::load_file(config_file)
          @token = @config['token']
        end
        self
      end
    end
  end
end
