require 'singleton'

module PhoneGap
  module Build
    class Credentials

      include Singleton

      attr_reader :username, :password, :token
      attr_writer :token

      def set(credentials)
        @username = credentials[:username]
        @password = credentials[:password]
        @token = credentials[:token]
        self
      end
    end
  end
end