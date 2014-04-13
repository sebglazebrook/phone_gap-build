require 'spec_helper'

describe PhoneGap::Build::App do

  it 'has a PATH of "apps"' do
    expect(subject.class.const_get('PATH')).to eq '/apps'
  end

  describe 'creatable attributes' do

    subject { PhoneGap::Build::App }

    %w(title create_method package version description debug keys private phonegap_version hydrates).each do |attribute|
      it "'#{attribute}' is updatable" do
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
end