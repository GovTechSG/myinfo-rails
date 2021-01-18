# frozen_string_literal: true

require 'net/http'

require_relative 'myinfo/errors'
require_relative 'myinfo/v3/api'
require_relative 'myinfo/v3/person_basic'

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
    attr_accessor :singpass_eservice_id, :app_id, :base_url, :client_id, :proxy, :encrypted, :private_key, :public_cert

    def initialize
      @encrypted = false
      @proxy = { address: nil, port: nil }
    end
  end

  # def authorize_url(nric_fin:, attributes:, redirect_uri:, purpose:, state:)
  #   query_string = {
  #     client_id: client_id,
  #     attributes: attributes,
  #     purpose: purpose,
  #     sp_esvcId: singpass_eservice_id,
  #     state: state,
  #     redirect_uri: redirect_uri
  #   }

  #   "#{base_url}/authorise/#{nric_fin}/?#{query_string.to_param}"
  # end
end
