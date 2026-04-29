require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v2"))
oauth = client.create_access_token(
  numbersip: ENV.fetch("NVOIP_NUMBERSIP"),
  user_token: ENV.fetch("NVOIP_USER_TOKEN")
)

puts JSON.pretty_generate(
  client.create_call(
    caller: ENV.fetch("NVOIP_CALLER"),
    called: ENV.fetch("NVOIP_TARGET_NUMBER", "11999999999"),
    access_token: oauth.fetch("access_token")
  )
)
