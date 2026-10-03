require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v3"))
response = client.create_client_credentials_token()

puts JSON.pretty_generate(response)
