# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

require_relative 'helpers/callable'

require_relative 'myinfo/errors'
require_relative 'myinfo/v3/api'
require_relative 'myinfo/v3/token'
require_relative 'myinfo/v3/person'
require_relative 'myinfo/v3/person_basic'
require_relative 'myinfo/v3/authorise_url'

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
    attr_accessor :singpass_eservice_id, :app_id, :base_url, :client_id, :proxy,
                  :sandbox, :private_key, :public_cert, :client_secret

    def initialize
      @sandbox = false
      @proxy = { address: nil, port: nil }
    end

    def sandbox?
      @sandbox
    end
  end
end
