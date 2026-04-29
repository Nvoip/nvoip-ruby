require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v2"))

puts JSON.pretty_generate(
  client.check_otp(
    code: ENV.fetch("NVOIP_OTP_CODE"),
    key: ENV.fetch("NVOIP_OTP_KEY")
  )
)
