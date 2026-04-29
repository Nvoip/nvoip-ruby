require "base64"
require "json"
require "net/http"
require "uri"

module Nvoip
  class Error < StandardError
    attr_reader :status, :payload

    def initialize(status, payload)
      super("Nvoip request failed with status #{status}: #{payload}")
      @status = status
      @payload = payload
    end
  end

  class Client
    def initialize(base_url: "https://api.nvoip.com.br/v2",
      oauth_client_id: ENV["NVOIP_OAUTH_CLIENT_ID"], oauth_client_secret: ENV["NVOIP_OAUTH_CLIENT_SECRET"])
      @base_url = base_url.sub(%r{/+$}, "")
      @oauth_client_id = oauth_client_id
      @oauth_client_secret = oauth_client_secret
    end

    def self.encode_basic_auth(client_id, client_secret)
      Base64.strict_encode64("#{client_id}:#{client_secret}")
    end

    def create_access_token(numbersip:, user_token:)
      request_form(
        "POST",
        "/oauth/token",
        {
          username: numbersip,
          password: user_token,
          grant_type: "password"
        },
        {
          "Authorization" => "Basic #{resolve_basic_auth}"
        }
      )
    end

    def refresh_access_token(refresh_token:)
      request_form(
        "POST",
        "/oauth/token",
        {
          grant_type: "refresh_token",
          refresh_token: refresh_token
        },
        {
          "Authorization" => "Basic #{resolve_basic_auth}"
        }
      )
    end

    def get_balance(access_token:)
      request("GET", "/balance", headers: auth_headers(access_token))
    end

    def send_sms(number_phone:, message:, flash_sms: false, access_token: nil, napikey: nil)
      request_json(
        "POST",
        "/sms",
        {
          numberPhone: number_phone,
          message: message,
          flashSms: flash_sms
        },
        access_token: access_token,
        napikey: napikey
      )
    end

    def create_call(caller:, called:, access_token:)
      request_json(
        "POST",
        "/calls/",
        {
          caller: caller,
          called: called
        },
        access_token: access_token
      )
    end

    def send_otp(payload:, access_token: nil, napikey: nil)
      request_json("POST", "/otp", payload, access_token: access_token, napikey: napikey)
    end

    def check_otp(code:, key:)
      request("GET", "/check/otp?code=#{URI.encode_www_form_component(code)}&key=#{URI.encode_www_form_component(key)}")
    end

    def list_whatsapp_templates(access_token:)
      request("GET", "/wa/listTemplates", headers: auth_headers(access_token))
    end

    def send_whatsapp_template(payload:, access_token:)
      request_json("POST", "/wa/sendTemplates", payload, access_token: access_token)
    end

    private

    def resolve_basic_auth
      return self.class.encode_basic_auth(@oauth_client_id, @oauth_client_secret) unless blank?(@oauth_client_id) || blank?(@oauth_client_secret)

      raise ArgumentError, "Missing OAuth client credentials. Configure oauth_client_id + oauth_client_secret."
    end

    def request_json(method, path, payload, access_token: nil, napikey: nil)
      request(
        method,
        with_napikey(path, napikey),
        headers: {
          "Content-Type" => "application/json"
        }.merge(access_token ? auth_headers(access_token) : {}),
        body: JSON.generate(payload)
      )
    end

    def request_form(method, path, payload, headers = {})
      request(
        method,
        path,
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded"
        }.merge(headers),
        body: URI.encode_www_form(payload)
      )
    end

    def request(method, path, headers: {}, body: nil)
      uri = URI("#{@base_url}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 30

      request = case method
      when "GET" then Net::HTTP::Get.new(uri)
      when "POST" then Net::HTTP::Post.new(uri)
      else
        raise ArgumentError, "Unsupported method: #{method}"
      end

      headers.each { |key, value| request[key] = value }
      request.body = body if body

      response = http.request(request)
      raw = response.body.to_s
      payload = raw.empty? ? {} : JSON.parse(raw)

      raise Error.new(response.code.to_i, payload) if response.code.to_i >= 400

      payload
    rescue JSON::ParserError
      payload = { "raw" => raw }
      raise Error.new(response.code.to_i, payload) if response.code.to_i >= 400

      payload
    end

    def with_napikey(path, napikey)
      return path if blank?(napikey)

      separator = path.include?("?") ? "&" : "?"
      "#{path}#{separator}napikey=#{URI.encode_www_form_component(napikey)}"
    end

    def auth_headers(access_token)
      { "Authorization" => "Bearer #{access_token}" }
    end

    def blank?(value)
      value.nil? || value == ""
    end
  end
end
