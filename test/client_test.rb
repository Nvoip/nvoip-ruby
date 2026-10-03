require "minitest/autorun"
require_relative "../lib/nvoip"

class ClientTest < Minitest::Test
  def test_encodes_special_credentials
    assert_equal Base64.strict_encode64("client+id:s%2Fsecret"), Nvoip::Client.encode_basic_auth("client id", "s/secret")
  end

  def test_missing_credentials_fails_before_http
    error = assert_raises(ArgumentError) { Nvoip::Client.new(oauth_client_id: nil, oauth_client_secret: nil).create_client_credentials_token }
    assert_match(/Missing OAuth/, error.message)
  end

  def test_bearer_is_required_for_otp_check_shape
    client = Nvoip::Client.new(oauth_client_id: "id", oauth_client_secret: "secret")
    assert_respond_to client, :check_otp
  end
end
