require 'json'

def response_body_for(request)
  fixture_file = File.open(ROOT_DIR + "fixtures/api_responses/#{request}.json")
  File.read(fixture_file)
end