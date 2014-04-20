require 'spec_helper'

describe PhoneGap::Build::ApiRequest do

  describe 'checking that configuration exists before sending a request' do

    %w(get post put delete).each do |request_action|

      describe "##{request_action}" do

        context 'without configuration set' do

          let(:credentials) { double( 'Credentials', token: false) }

          before do
            PhoneGap::Build::Credentials.stub(:instance).and_return credentials
          end

          it 'looks for credentials configuration' do
            expect(credentials).to receive(:load).and_return credentials
            subject.send request_action, 'path'
          end

          context 'when credentials configuration exists' do

            before do
              credentials.stub(:load).and_return credentials
              credentials.stub(:token).and_return 'BATMAN TOKEN'
            end

            it 'makes the api call' do
              expect(subject.class).to receive(request_action.to_sym)
              subject.send request_action, 'path'
            end
          end

          context 'when credentials configuration does not exist' do

            before do
              credentials.stub(:load).and_return false
            end

            it 'returns an error' do
              expect(subject.send(request_action, 'path').message).to eq 'Api credentials not found. Set them or add them to config/phonegap.yml'
            end
          end
        end
      end
    end
  end

  context 'when credentials exist' do

    let(:token) { 'BATMAN' }

    before do
      PhoneGap::Build::Credentials.instance.set(token: token)
    end

    describe '#get' do

      it 'sends a GET request to the given path with the auth_token included' do
        expect(subject.class).to receive(:get).with('some fancy path?auth_token=BATMAN')
        subject.get('some fancy path')
      end
    end

    describe '#post' do

      it 'sends a POST request to the given path with the auth_token included' do
        expect(subject.class).to receive(:post).with('some fancy path?auth_token=BATMAN', anything)
        subject.post('some fancy path')
      end

      context 'when query params are available' do

        let(:query_params) { { data: {id: 1, title: 'seb'}} }

        it 'sends them through with the request' do
          expect(subject.class).to receive(:post).with(anything, query: query_params)
          subject.post('some fancy path', query: query_params)
        end
      end
    end

    describe '#put' do

      it 'send a PUT request to the given path with the auth_token included' do
        expect(subject.class).to receive(:put).with('some fancy path?auth_token=BATMAN', anything)
        subject.put('some fancy path')
      end

      context 'when query params are available' do

        let(:query_params) { { data: {id: 1, title: 'seb'}} }

        it 'sends them through with the request' do
          expect(subject.class).to receive(:put).with(anything, query: query_params)
          subject.put('some faNCY PATH', query: query_params)
        end
      end
    end

    describe '#delete' do

      it 'send a DELETE request to the given path with the auth_token included' do
        expect(subject.class).to receive(:delete).with('some fancy path?auth_token=BATMAN')
        subject.delete('some fancy path')
      end
    end
  end
end