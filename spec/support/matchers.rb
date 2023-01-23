RSpec::Matchers.define :uri_including do |*expected|
  match do |actual|
    parsed_url = CGI.parse(actual.to_s).to_s

    expected.all? { |expected_item| parsed_url.match?(expected_item) }
  rescue URI::InvalidURIError
    false
  end
end