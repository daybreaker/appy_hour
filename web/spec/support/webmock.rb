require 'webmock/rspec'

# Disable all real HTTP connections in tests.
# Use WebMock.stub_request in specs that need to simulate outbound calls
# (Google Places API, Claude API, website scraping).
WebMock.disable_net_connect!(allow_localhost: true)
