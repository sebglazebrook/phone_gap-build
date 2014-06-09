require 'spec_helper'

describe PhoneGap::Build::PackageDownloader do

  let(:api_request) { double('PhoneGap::Build::ApiRequest') }

  before do
    PhoneGap::Build::ApiRequest.stub(:new).and_return api_request
  end

  context 'when given a package' do

    let(:platform) { 'some platform' }

    context 'and an app id' do

      let(:id) { 'id' }
      let(:http_response) { double('response', :success? => false, body: '{"key":"value"}') }

      it 'makes an api call to download the package' do
        expect(api_request).to receive(:get).with("/apps/#{id}/#{platform}").and_return http_response
        subject.download(id, platform)
      end

      context 'when the api call is successful' do

        let(:file_name) { 'Something.ipa' }
        let(:uri) { double('uri', request_uri: "/ios.phonegap/slicehost-production/apps/894786/#{file_name}" ) }
        let(:request) { double('request') }
        let(:http_response) { double('http response', success?: true, request: request, body: 'file content') }

        before do
          api_request.stub(:get).and_return http_response
          request.stub(:instance_variable_get).with(:@last_uri).and_return uri
          FileUtils.stub(:mkdir_p)
          File.stub(:open)
        end

        it 'creates a directory to store the file' do
          expect(FileUtils).to receive(:mkdir_p)
          subject.download(id, platform)
        end

        context 'and given a directory to save to' do

          let(:target_dir) { '/save/me/here' }

          it 'saves each package to the given folder' do
            expect(File).to receive(:open).with("#{target_dir}/#{platform}/#{file_name}", anything)
            subject.download(id, platform, target_dir)
          end
        end

        context 'and not given a directory to save to' do

          it 'saves the package to the tmp folder' do
            expect(File).to receive(:open).with("/tmp/#{platform}/#{file_name}", anything)
            subject.download(id, platform)
          end
        end
      end
    end
  end
end