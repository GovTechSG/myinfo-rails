# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

require_relative 'myinfo/errors'

require_relative 'myinfo/helpers/callable'
require_relative 'myinfo/helpers/attributes'
require_relative 'myinfo/helpers/jwe_decryptor'
require_relative 'myinfo/helpers/security_helper'

require_relative 'myinfo/v3/response'
require_relative 'myinfo/v3/api'
require_relative 'myinfo/v3/token'
require_relative 'myinfo/v3/person'
require_relative 'myinfo/v3/person_basic'
require_relative 'myinfo/v3/authorise_url'

require_relative 'myinfo/v4/response'
require_relative 'myinfo/v4/api'
require_relative 'myinfo/v4/session'
require_relative 'myinfo/v4/authorise_url'
require_relative 'myinfo/v4/token'
require_relative 'myinfo/v4/person'

# Base MyInfo class
module MyInfo
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # Configuration to set various properties needed to use MyInfo
  class Configuration
    attr_accessor :singpass_eservice_id,
                  :app_id,
                  :client_id,
                  :proxy,
                  :private_key,
                  :public_cert,
                  :client_secret,
                  :redirect_uri,
                  :gateway_url,
                  :gateway_key,
                  :authorise_jwks_base_url, # added for v4
                  :subentity_id, # added for v4, UEN of SaaS partner's client that will be receiving the person data.
                  :private_encryption_key, # added for V4
                  :private_signing_key # added for V4

    attr_reader :base_url
    attr_writer :public_facing, :sandbox

    def initialize
      @public_facing = false
      @sandbox = false
      @proxy = { address: nil, port: nil }
    end

    def base_url=(url)
      @base_url = url.sub('https://', '').split('/').first
    end

    def base_url_with_protocol
      "https://#{base_url}"
    end

    def gateway_host
      gateway_url&.sub('https://', '')&.split('/')&.first
    end

    def gateway_path
      gateway_url.present? ? gateway_url.sub('https://', '').split('/')[1..].join('/') : ''
    end

    def public?
      @public_facing
    end

    def sandbox?
      @sandbox
    end
  end
end
