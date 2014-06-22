require 'spec_helper'

describe PhoneGap::Build::Credentials do

  subject { PhoneGap::Build::Credentials .instance }

  describe '#load' do

    let(:config_file) { File.expand_path('config/phonegap.yml', ROOT_DIR) }

    before do
      File.stub(:exists?).with(config_file).and_return true
    end

    context 'when run in the context fo bundler' do

      before do
        ENV.stub(:[]).with('BUNDLE_GEMFILE').and_return(File.join(ROOT_DIR, 'Gemfile'))
      end

      it 'tries to load a phonegap config file' do
        expect(YAML).to receive(:load_file).with(config_file).and_return({})
        subject.load
      end

      context 'if a config file exists' do

        before do
          YAML.stub(:load_file).and_return({'token' => 'BATMAN'})
        end

        it 'populates the credentials using values from the config file' do
          subject.load
          expect(subject.token).to eq 'BATMAN'
        end
      end
    end
  end
end