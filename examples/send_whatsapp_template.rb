require "json"
require_relative "../lib/nvoip"

client = Nvoip::Client.new(base_url: ENV.fetch("NVOIP_BASE_URL", "https://api.nvoip.com.br/v2"))
oauth = client.create_access_token(
  numbersip: ENV.fetch("NVOIP_NUMBERSIP"),
  user_token: ENV.fetch("NVOIP_USER_TOKEN")
)

payload = {
  idTemplate: ENV.fetch("NVOIP_WA_TEMPLATE_ID"),
  destination: ENV.fetch("NVOIP_WA_DESTINATION", ENV.fetch("NVOIP_TARGET_NUMBER", "11999999999")),
  instance: ENV.fetch("NVOIP_WA_INSTANCE"),
  language: ENV.fetch("NVOIP_WA_LANGUAGE", "pt_BR")
}

body_variables = JSON.parse(ENV.fetch("NVOIP_WA_BODY_VARIABLES", "[]"))
header_variables = JSON.parse(ENV.fetch("NVOIP_WA_HEADER_VARIABLES", "[]"))
payload[:bodyVariables] = body_variables unless body_variables.empty?
payload[:headerVariables] = header_variables unless header_variables.empty?
payload[:functions] = { to_flow: true } if ENV.fetch("NVOIP_WA_TO_FLOW", "false").downcase == "true"

puts JSON.pretty_generate(client.send_whatsapp_template(payload: payload, access_token: oauth.fetch("access_token")))
