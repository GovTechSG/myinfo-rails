# frozen_string_literal: true

module MyInfo
  class MyInfoError < StandardError; end

  class MissingConfigurationError < MyInfoError; end

  class UnavailableError < MyInfoError; end
end
