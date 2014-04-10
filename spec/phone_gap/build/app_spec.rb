require 'spec_helper'

describe PhoneGap::Build::App do

  describe 'upon instantiation' do

    context 'when given parameters' do

      let(:params) do
        { name: 'Batman', title: 'Dark Knight', status: { height: 'tall', weight: 'heavy'} }
      end

      subject { PhoneGap::Build::App.new(params) }

      it 'makes an attribute of each parameter' do
        expect(subject.name).to eq 'Batman'
        expect(subject.title).to eq 'Dark Knight'
        expect(subject.status).to eq({height: 'tall', weight: 'heavy'})
      end
    end
  end
end