# frozen_string_literal: true

module MyInfo
  # Attributes parsing
  module Attributes
    DEFAULT_VALUES = %i[name sex race dob residentialstatus email mobileno regadd].freeze

    def self.parse(attributes)
      attributes ||= DEFAULT_VALUES

      attributes.is_a?(String) ? attributes : attributes.join(',')
    end
  end
end
