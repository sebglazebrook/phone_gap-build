module PhoneGap
  module Build
    class ApiRequest

      include HTTMultiParty
      base_uri 'https://build.phonegap.com/api/v1'

      def get(path)
        if credentials?
          self.class.get("#{path}?auth_token=#{token}")
        else
          credentials_not_found
        end
      end

      def post(path, params = {})
        if credentials?
          self.class.post("#{path}?auth_token=#{token}", query: params[:query])
        else
          credentials_not_found
        end
      end

      def put(path, params = {})
        if credentials?
          self.class.put("#{path}?auth_token=#{token}", query: params[:query])
        else
          credentials_not_found
        end
      end

      def delete(path, params = {})
        if credentials?
          self.class.delete("#{path}?auth_token=#{token}")
        else
          credentials_not_found
        end
      end

      private

      def credentials?
        if PhoneGap::Build::Credentials.instance.token
          true
        else
          Credentials.instance.load
          PhoneGap::Build::Credentials.instance.token
        end
      end

      def credentials_not_found
        Error.new(message: 'Api credentials not found. Set them or add them to config/phonegap.yml')
      end

      def token
        PhoneGap::Build::Credentials.instance.token
      end
    end
  end
end