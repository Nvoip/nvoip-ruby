require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v2"))
oauth = client.create_access_token(
  numbersip: ENV.fetch("NVOIP_NUMBERSIP"),
  user_token: ENV.fetch("NVOIP_USER_TOKEN")
)

payload = {
  idTemplate: ENV.fetch("NVOIP_WA_TEMPLATE_ID"),
  instance: ENV.fetch("NVOIP_WA_INSTANCE"),
  language: ENV.fetch("NVOIP_WA_LANGUAGE", "pt_BR")
}

recipient_type = ENV.fetch("NVOIP_WA_RECIPIENT_TYPE", "").strip.downcase
recipient_value = ENV.fetch("NVOIP_WA_RECIPIENT_VALUE", "").strip
if recipient_type.empty?
  destination = ENV.fetch("NVOIP_WA_DESTINATION", ENV.fetch("NVOIP_TARGET_NUMBER", ""))
  raise "NVOIP_WA_DESTINATION must be a phone number; use recipient for BSUID" unless destination.match?(/\A\+?\d{8,20}\z/)
  payload[:destination] = destination
else
  unless %w[phone bsuid parent_bsuid].include?(recipient_type) && !recipient_value.empty?
    raise "NVOIP_WA_RECIPIENT_TYPE must be phone, bsuid or parent_bsuid and requires NVOIP_WA_RECIPIENT_VALUE"
  end
  raise "@username is not a WhatsApp recipient; use a BSUID or parent BSUID" if recipient_value.start_with?("@")
  if recipient_type == "phone" && !recipient_value.match?(/\A\+?\d{8,20}\z/)
    raise "A phone recipient must contain only an optional leading + and 8 to 20 digits"
  end
  if recipient_type != "phone" && (recipient_value.match?(/\s/) || recipient_value.length > 256)
    raise "A BSUID must be an opaque value without whitespace (maximum 256 characters)"
  end
  payload[:recipient] = { type: recipient_type, value: recipient_value }
end

body_variables = JSON.parse(ENV.fetch("NVOIP_WA_BODY_VARIABLES", "[]"))
header_variables = JSON.parse(ENV.fetch("NVOIP_WA_HEADER_VARIABLES", "[]"))
payload[:bodyVariables] = body_variables unless body_variables.empty?
payload[:headerVariables] = header_variables unless header_variables.empty?
if ENV.fetch("NVOIP_WA_TO_FLOW", "false").downcase == "true"
  raise "WhatsApp Flow and attendance require a phone recipient" if %w[bsuid parent_bsuid].include?(recipient_type)
  payload[:functions] = { to_flow: true }
end

puts JSON.pretty_generate(client.send_whatsapp_template(payload: payload, access_token: oauth.fetch("access_token")))
