require 'spec_helper'

describe PhoneGap::Build::App do

  let(:api_request) { double('PhoneGap::Build::ApiRequest') }

  before do
    PhoneGap::Build::ApiRequest.stub(:new).and_return api_request
  end

  it 'has a PATH of "apps"' do
    expect(subject.class.const_get('PATH')).to eq '/apps'
  end

  describe 'creatable attributes' do

    subject { PhoneGap::Build::App }

    %w(title create_method package version description debug keys private phonegap_version hydrates).each do |attribute|
      it "'#{attribute}' is creatable" do
        expect(subject.class_variable_get('@@creatable_attributes')[subject]).to include "@#{attribute}"
      end
    end
  end

  describe 'updatable attributes' do

    subject { PhoneGap::Build::App }

    %w(title package version description debug private phonegap_version).each do |attribute|
      it "'#{attribute}' is updatable" do
        expect(subject.class_variable_get('@@updatable_attributes')[subject]).to include "@#{attribute}"
      end
    end
  end

  describe '#create' do

    let(:api_request) { double('PhoneGap::Build::ApiRequest') }
    let(:response) { double('response', :success? => false, body: '{"key":"value"}') }

    context 'when there are populated and non-populated creatable variables' do

      before do
        subject.title = 'title'
        subject.create_method = 'create method'
        subject.package = nil
        PhoneGap::Build::ApiRequest.stub(:new).and_return api_request
      end

      it 'sends query data for all creatable attributes that do not have a value of nil' do
        expected_options = { query: {data: { title: 'title', create_method: 'create method'}}}
        expect(api_request).to receive(:post).with(anything, expected_options).and_return response
        subject.create
      end

      context 'when a file is present' do

        let(:file) { fixture_file('index.html') }

        before do
          subject.file = file
        end

        it 'sends the file through as part of the query' do
          expected_options =
              { query: { file: file, data: {title: 'title', create_method: 'create method'}}, detect_mime_type: true}
          expect(api_request).to receive(:post).with(anything, expected_options).and_return response
          subject.create
        end
      end
    end
  end

  context 'for an existing app' do

    let(:id) { '1' }

    before do
      subject.instance_variable_set('@id',id)
    end

    describe '#build' do

      context 'when the app has an id' do

        let(:id) { 1 }
        let(:api_request) { double('PhoneGap::Build::ApiRequest') }

        before do
          subject.instance_variable_set('@id', id)
        end

        it 'sends a POST request to build the app' do
          expect(api_request).to receive(:post).with("/apps/#{subject.id}/build")
          subject.build
        end
      end
    end

    describe '#build_complete?' do

      let(:http_response) { double('http response', success?: true, body: '{"status": { "ios": "complete"}}') }

      before do
        api_request.stub(:get).with("/apps/#{id}").and_return http_response
        subject.poll_time_limit = 0.1
        subject.poll_interval = 0
      end

      it 'polls the api to see if the app has finished building' do
        expect(api_request).to receive(:get).with("/apps/#{id}").and_return http_response
        subject.build_complete?
      end

      context 'with a poll interval of 0.09 second' do

        before do
          subject.poll_interval = 0.09
        end

        context 'when not given a time limit' do

          context 'with a poll interval of 0.1 seconds' do

            before do
              subject.poll_interval = 0.1
            end

            it 'checks every 0.09 seconds until the default time limit is exceeded' do
              subject.poll_time_limit = 0.09
              expect(api_request).to receive(:get).with("/apps/#{id}").exactly(1).times
              subject.build_complete?
            end
          end
        end

        context 'when supplied with a time limit' do

          it 'checks every 0.1 seconds until the supplied time limit has exceeded' do
            expect(api_request).to receive(:get).with("/apps/#{id}").exactly(1).times
            subject.build_complete?(poll_time_limit: 0.09)
          end

        end

        context 'when the build is complete' do

          let(:http_response) { double('http response', success?: true, body: response_body_for('get-app') ) }

          it 'returns true' do
            expect(subject.build_complete?).to be_true
          end
        end

        context 'when the build doesnt complete' do

          let(:http_response) { double('http response', success?: true, body: '{"status": { "ios": "nil"}}') }

          it 'returns throws an exception' do
            expect{subject.build_complete?}.to raise_error PhoneGap::Build::BuildError
          end
        end

        context 'when there was an error building' do

          let(:http_response) { double('http response', success?: true, body: '{"status": { "ios": "error"}}') }

          it 'returns throws an exception' do
            expect{subject.build_complete?}.to raise_error PhoneGap::Build::BuildError
          end
        end
      end
    end

    describe '#download' do

      let(:http_response) { double('http response', success?: false) }

      before do
        api_request.stub(:get).and_return http_response
      end

      context 'when there are builds that are complete' do

        before do
          subject.instance_variable_set('@status', { android: 'complete', ios: 'complete', winphone: 'complete' })
        end

        context 'when no specific platforms are specified' do

          let(:platforms) { %w(android ios winphone) }

          it 'downloads each platform\'s package' do
            platforms.each do |platform|
              expect(api_request).to receive(:get).with("/apps/#{id}/#{platform}")
            end
            subject.download
          end
        end

        context 'when specific packages are specified' do

          let(:platforms) { %w(ios android) }

          it 'downloads the specific packages' do
            platforms.each do |platform|
              expect(api_request).to receive(:get).with("/apps/#{id}/#{platform}")
            end
            subject.download(platforms: platforms)
          end
        end

        context 'when the download response is successful' do

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
            subject.download
          end

          context 'and given a directory to save to' do

            let(:target_dir) { '/save/me/here' }

            it 'saves each package to the given folder' do
              expect(File).to receive(:open).with("#{target_dir}/ios/#{file_name}", anything)
              expect(File).to receive(:open).with("#{target_dir}/android/#{file_name}", anything)
              expect(File).to receive(:open).with("#{target_dir}/winphone/#{file_name}", anything)
              subject.download(save_to: target_dir)
            end
          end

          context 'and not given a directory to save to' do

            it 'saves the package to the tmp folder' do
              expect(File).to receive(:open).with("/tmp/ios/#{file_name}", anything)
              expect(File).to receive(:open).with("/tmp/android/#{file_name}", anything)
              expect(File).to receive(:open).with("/tmp/winphone/#{file_name}", anything)
              subject.download
            end
          end
        end
      end
    end
  end
end