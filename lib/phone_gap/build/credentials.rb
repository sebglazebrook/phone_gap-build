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
        if config_file && File.exists?(config_file)
          @config = YAML::load(ERB.new(File.read(config_file)).result)
          @token = @config['token']
        end
        self
      end

      private

      def config_file
        if ENV['BUNDLE_GEMFILE']
          application_root = ENV['BUNDLE_GEMFILE'].gsub('Gemfile', '')
          File.expand_path(File.join(application_root, 'config', 'phonegap.yml'), __FILE__)
        else
          false
        end
      end
    end
  end
end
