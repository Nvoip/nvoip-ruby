Gem::Specification.new do |spec|
  spec.name = "nvoip"
  spec.version = "0.1.0"
  spec.summary = "SDK Ruby oficial para a API v2 da Nvoip"
  spec.description = "SDK Ruby oficial para integrar OAuth, chamadas, OTP, WhatsApp, SMS e saldo com a API v2 da Nvoip."
  spec.authors = ["Nvoip"]
  spec.homepage = "https://www.nvoip.com.br/"
  spec.license = "GPL-3.0-only"
  spec.files = Dir["lib/**/*", "README.md", "LICENSE", ".env.example"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0"
  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/Nvoip/nvoip-ruby/issues",
    "documentation_uri" => "https://nvoip.docs.apiary.io/",
    "homepage_uri" => "https://www.nvoip.com.br/",
    "source_code_uri" => "https://github.com/Nvoip/nvoip-ruby"
  }
end
