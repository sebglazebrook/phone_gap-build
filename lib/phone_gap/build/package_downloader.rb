module PhoneGap
  module Build
    class PackageDownloader

      attr_reader :id, :platform, :target_dir, :http_response

      def download(id, platform, target_dir = '/tmp')
        @id, @platform, @target_dir = id, platform, target_dir
        @http_response = PhoneGap::Build::ApiRequest.new.get("/apps/#{id}/#{platform}")
        save_file if http_response.success?
      end

      private

      def save_file
        FileUtils.mkdir_p(platform_output_dir)
        puts "Saving to #{file_path}"
        File.open(file_path, 'w+') { |f| f.write(http_response.body) }
        puts 'Download complete'
      end

      def platform_output_dir
        File.join(target_dir, platform.to_s)
      end

      def file_path
        File.join(platform_output_dir, file_name)
      end

      def file_name
        file_name_from_uri(http_response.request.instance_variable_get(:@last_uri).request_uri)
      end

      def file_name_from_uri(uri)
        uri.match(/\/([^\/]*)$/)[0]
      end
    end
  end
end
