require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v2"))
oauth = client.create_access_token(
  numbersip: ENV.fetch("NVOIP_NUMBERSIP"),
  user_token: ENV.fetch("NVOIP_USER_TOKEN")
)

payload = {}
payload[:sms] = ENV["NVOIP_OTP_SMS"] || ENV["NVOIP_TARGET_NUMBER"] if ENV["NVOIP_OTP_SMS"] || ENV["NVOIP_TARGET_NUMBER"]
payload[:voice] = ENV["NVOIP_OTP_VOICE"] if ENV["NVOIP_OTP_VOICE"]
payload[:email] = ENV["NVOIP_OTP_EMAIL"] if ENV["NVOIP_OTP_EMAIL"]

puts JSON.pretty_generate(client.send_otp(payload: payload, access_token: oauth.fetch("access_token")))
