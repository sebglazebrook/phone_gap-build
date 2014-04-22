require 'spec_helper'

describe PhoneGap::Build::RestResource do

  let(:base_uri) { 'https://build.phonegap.com/api/v1/' }
  let(:api_request) { double('ApiRequest') }

  before do
    PhoneGap::Build::ApiRequest.stub(:new).and_return api_request
  end

  it 'has a default poll_time_limit of 120' do
    expect(subject.poll_time_limit).to eq 120
  end

  it 'has a default poll_interval of 5' do
    expect(subject.poll_interval).to eq 5
  end

  context 'when an authentication token is present' do

    let(:token) { 'BATMAN' }

    before do
      PhoneGap::Build::Credentials.instance.token = token
    end

    context 'when used in a child class' do

      class Child < PhoneGap::Build::RestResource

        attr_accessor :id, :file

        PATH = 'users'

      end

      subject { Child.new }

      describe '#create' do

        let(:response) { double('response', success?: false, body: '{"key": "value"}') }

        before do
         api_request.stub(:post).with('users', query: {data: subject.as_json}).and_return response
        end

        it 'sends POST request' do
          expect(api_request).to receive(:post).and_return response
          subject.create
        end

        it 'uses the resource base as the path and includes the auth token in the request' do
          expect(api_request).to receive(:post).with("users", anything).and_return response
          subject.create
        end

        context 'child class has #post_options' do

          let(:post_options) { lambda{ 'wonder woman'} }

          before do
            subject.define_singleton_method(:post_options, post_options)
          end

          it 'posts using options from the child class' do
            expect(api_request).to receive(:post).with(anything, 'wonder woman').and_return response
            subject.create
          end
        end

        context 'child class does not have #post_options' do

          it 'sends a body containing all the json representation of the object' do
            expect(api_request).to receive(:post).with(anything, query: {data: subject.as_json}).and_return response
            subject.create
          end
        end

        context 'when creation is successful' do

          let(:success_response) { double('response', success?: true, body: '{"id" : 1, "title" : "Batman", "rating" : 5}') }

          before do
            api_request.stub(:post).with('users', query: {data: {}}).and_return success_response
          end

          it 'updates the object with any response attributes' do
            response = subject.create
            expect(response.object_id).to be subject.object_id
            expect(response.instance_variable_get('@id')).to eq 1
            expect(response.instance_variable_get('@title')).to eq 'Batman'
            expect(response.instance_variable_get('@rating')).to eq 5
          end
        end

        context 'when creation is unsuccessful' do

          let(:response) { double('response', success?: false, body: "{\"error\":\"Error: upload failed; please try again\"}\n") }

          it 'returns false' do
            expect(subject.create).to eq false
          end

          it 'updates the object with the errors' do
            subject.create
            expect(subject.errors).to eq ['Error: upload failed; please try again']
          end
        end
      end

      describe '#update' do

        context 'when the object has an id' do

          let(:id) { double('id') }

          before do
            subject.id = id
          end

          it 'sends PUT request' do
            expect(api_request).to receive(:put)
            subject.update
          end

          it 'uses the resource base as the path and includes the auth token in the request' do
            expect(api_request).to receive(:put).with("users/#{id}", anything)
            subject.update
          end

          it 'send a body containing all the json representation of the object' do
            expect(api_request).to receive(:put).with(anything, query: {data: {}})
            subject.update
          end

          context 'after successful update' do

            it 'returns the populated object'

          end
        end
      end

      describe '#save' do

        context 'when the child object has an id attribute' do

          before do
            subject.id = 69
          end

          it 'attempts to update an existing item' do
            expect(api_request).to receive(:put)
            subject.save
          end
        end

        context 'when the child object doesn\'t have an id attribute' do

          let(:http_response) { double('response', success?: false, body: '{"key":"value"}') }

          before do
            subject.id = nil
          end

          it 'attempts to create a new item' do
            expect(api_request).to receive(:post).and_return http_response
            subject.save
          end
        end
      end

      describe '#destroy' do

        context 'when the object has an id' do

          let(:id) { double('id') }

          before do
            subject.id = id
          end

          it 'sends DELETE request' do
            expect(api_request).to receive(:delete)
            subject.destroy
          end

          it 'includes the auth token in the request' do
            expect(api_request).to receive(:delete).with("users/#{id}")
            subject.destroy
          end

          context 'upon successful deletion' do

            it 'does something'

          end
        end

        context 'when the object does not have an id' do

          it 'returns an error'

        end
      end

      describe '#as_json' do

        context 'when there are instance variables' do

          before do
            subject.instance_variable_set('@superman', 'superman')
            subject.instance_variable_set('@spiderman', 'spiderman')
            subject.instance_variable_set('@batman', 'batman')
          end

          context 'when given a list of variables to use' do

            let(:attributes) { ['@superman', '@spiderman'] }

            it 'returns a hash of the given attributes and their values' do
              expect(subject.as_json(only: attributes)).to eq({superman: 'superman', spiderman: 'spiderman'})
            end
          end
        end
      end
    end
  end
end
