require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v3"))
oauth = client.create_client_credentials_token()

payload = { methods: {} }
if (phone_number = ENV["NVOIP_OTP_SMS"] || ENV["NVOIP_TARGET_NUMBER"])
  payload[:phoneNumber] = phone_number
  payload[:methods][:sms] = true
end
if (email = ENV["NVOIP_OTP_EMAIL"])
  payload[:email] = email
  payload[:methods][:email] = true
end
raise "Configure NVOIP_OTP_SMS/NVOIP_TARGET_NUMBER or NVOIP_OTP_EMAIL" if payload[:methods].empty?

puts JSON.pretty_generate(client.send_otp(payload: payload, access_token: oauth.fetch("access_token")))
