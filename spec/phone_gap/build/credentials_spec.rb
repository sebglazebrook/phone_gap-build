require 'spec_helper'

describe PhoneGap::Build::Credentials do

  subject { PhoneGap::Build::Credentials .instance }

  describe '#load' do

    context 'when run in the context fo bundler' do

      before do
        ENV.stub(:[]).with('BUNDLE_GEMFILE').and_return(File.join(ROOT_DIR, 'Gemfile'))
      end

      context 'and a config file exists' do

        let(:config_file) { File.expand_path('config/phonegap.yml', ROOT_DIR) }
        let(:config_double) { double('config') }
        let(:erb_double) { double('erb', :result => config_file) }

        before do
          File.stub(:exists?).with(config_file).and_return true
          File.stub(:read).with(config_file).and_return config_double
          ERB.stub(:new).with(config_double).and_return erb_double
        end


        it 'evaluates any embedded ruby' do
          expect(ERB).to receive(:new).with(config_double).and_return erb_double
          subject.load
        end

        it 'tries to load a phonegap config file' do
          expect(YAML).to receive(:load).with(config_file).and_return({})
          subject.load
        end

        context 'if a token exists in config' do

          before do
            YAML.stub(:load).and_return({'token' => 'BATMAN'})
          end

          it 'populates the credentials using values from the config file' do
            subject.load
            expect(subject.token).to eq 'BATMAN'
          end
        end
      end
    end
  end
end