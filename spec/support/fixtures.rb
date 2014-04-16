require 'json'

def response_body_for(request)
  fixture_file = File.open(ROOT_DIR + "fixtures/api_responses/#{request}.json")
  File.read(fixture_file)
end

def fixture_file(filename)
  File.new(ROOT_DIR + "fixtures/#{filename}")
end