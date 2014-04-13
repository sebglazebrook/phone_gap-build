require 'spec_helper'

describe PhoneGap::Build::RestResource do

  let(:base_uri) { 'https://build.phonegap.com/api/v1/' }

  context 'when an authentication token is present' do

    let(:token) { 'BATMAN' }

    before do
      PhoneGap::Build::Credentials.instance.token = token
    end

    context 'when used in a child class' do

      class Child < PhoneGap::Build::RestResource

        attr_accessor :id

        PATH = 'users'

      end

      subject { Child.new }

      describe '#create' do

        let(:response) { double('response', success?: false) }

        before do
          subject.class.stub(:post).with("users?auth_token=#{token}", query: {data: subject.as_json}).and_return response
        end

        it 'sends POST request' do
          expect(subject.class).to receive(:post).and_return response
          subject.create
        end

        it 'uses the resource base as the path and includes the auth token in the request' do
          expect(subject.class).to receive(:post).with("users?auth_token=#{token}", anything()).and_return response
          subject.create
        end

          it 'sends a body containing all the json representation of the object' do
            expect(subject.class).to receive(:post).with(anything(), query: {data: {}}).and_return response
            subject.create
          end

        context 'after successful creation' do

          let(:success_response) { double('response', success?: true, body: '{"title" : "Batman", "rating" : 5}') }

          before do
            subject.class.stub(:post).with("users?auth_token=#{token}", query: {data: {}}).and_return success_response
          end

          it 'updates the object with any response attributes' do
            response = subject.create
            expect(response).to be_kind_of Child
            expect(response.instance_variable_get('@title')).to eq 'Batman'
            expect(response.instance_variable_get('@rating')).to eq 5
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
            expect(subject.class).to receive(:put)
            subject.update
          end

          it 'uses the resource base as the path and includes the auth token in the request' do
            expect(subject.class).to receive(:put).with("users/#{id}?auth_token=#{token}", anything())
            subject.update
          end

          it 'send a body containing all the json representation of the object' do
            expect(subject.class).to receive(:put).with(anything(), query: {data: {}})
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
            expect(subject.class).to receive(:put)
            subject.save
          end
        end

        context 'when the child object doesn\'t have an id attribute' do

          let(:http_response) { double('response', success?: false) }

          before do
            subject.id = nil
            subject.class.stub(:post).and_return http_response
          end

          it 'attempts to create a new item' do
            expect(subject.class).to receive(:post)
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
            expect(subject.class).to receive(:delete)
            subject.destroy
          end

          it 'includes the auth token in the request' do
            expect(subject.class).to receive(:delete).with("users/#{id}?auth_token=#{token}")
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