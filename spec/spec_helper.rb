require 'rspec'
require_relative '../lib/phone_gap/build'

ROOT_DIR = Pathname.new(File.expand_path('..', __FILE__))

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end




