module PhoneGap
  module Build
    class Credentials

      attr_reader :username, :password, :token

      def initialize(params)
        @username, @password, @token = params[:username], params[:password], params[:token]
      end
    end
  end
end