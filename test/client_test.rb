require "minitest/autorun"
require_relative "../lib/nvoip"

class ClientTest < Minitest::Test
  FakeResponse = Struct.new(:code, :body)

  def capture(status: "200", body: "{}")
    captured = []
    fake = Object.new
    fake.define_singleton_method(:use_ssl=) { |_| }
    fake.define_singleton_method(:read_timeout=) { |_| }
    fake.define_singleton_method(:request) { |request| captured << request; FakeResponse.new(status, body) }
    Net::HTTP.stub(:new, fake) { yield captured }
  end

  def test_encodes_special_credentials
    assert_equal Base64.strict_encode64("client+id:s%2Fsecret"), Nvoip::Client.encode_basic_auth("client id", "s/secret")
  end

  def test_missing_credentials_fails_before_http
    error = assert_raises(ArgumentError) { Nvoip::Client.new(oauth_client_id: nil, oauth_client_secret: nil).create_client_credentials_token }
    assert_match(/Missing OAuth/, error.message)
  end

  def test_bearer_is_required_for_otp_check_shape
    client = Nvoip::Client.new(base_url: "http://local/v3", oauth_client_id: "id", oauth_client_secret: "secret", token_url: "http://local/token")
    capture { |requests| client.check_otp(code: "123", key: "key", access_token: "bearer-value"); assert_equal "/v3/check/otp?code=123&key=key", requests.first.path; assert_equal "Bearer bearer-value", requests.first["Authorization"] }
  end

  def test_serializes_token_refresh_balance_and_error
    client = Nvoip::Client.new(base_url: "http://local/v3", oauth_client_id: "client id", oauth_client_secret: "s/secret", token_url: "http://local/token")
    capture { |requests| client.create_client_credentials_token; request = requests.first; assert_equal "/token", request.path; assert_equal "grant_type=client_credentials", request.body; assert_equal "Basic Y2xpZW50K2lkOnMlMkZzZWNyZXQ=", request["Authorization"] }
    capture { |requests| client.refresh_access_token(refresh_token: "a b"); assert_equal "grant_type=refresh_token&refresh_token=a+b", requests.first.body }
    capture { |requests| client.get_balance(access_token: "bearer-value"); assert_equal "Bearer bearer-value", requests.first["Authorization"] }
    assert_raises(Nvoip::Error) { capture(status: "401", body: '{"error":"invalid"}') { client.get_balance(access_token: "bad") } }
  end
end
