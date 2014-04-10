require 'spec_helper'
require 'httparty'

describe PhoneGap::Build do

  subject { PhoneGap::Build }

  describe '#credentials' do

    describe 'token authentication' do

      it 'gets stored for future api calls' do
        subject.credentials(token: 'some awesome token')
        expect(subject.instance_variable_get(:'@credentials').token).to eq 'some awesome token'
      end
    end
  end

  context 'with token authentication' do

    let(:token) { 'BATMAN' }

    before do
      subject.credentials(token: token)
    end

    describe '#apps' do

      let(:url) { "https://build.phonegap.com/api/v1/apps?auth_token=#{token}" }
      let(:api_response) { double(body: response_body_for('get-apps')) }

      before do
        HTTParty.stub(:get).with(url).and_return api_response
      end

      it 'makes a call to the api' do
        expect(HTTParty).to receive(:get).with(url).and_return api_response
        subject.apps
      end

      it 'returns a collection of apps' do
        expect(subject.apps.size).to eq 2
        expect(subject.apps.first).to be_kind_of PhoneGap::Build::App
      end
    end
  end
end
