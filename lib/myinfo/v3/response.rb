# frozen_string_literal: true

module MyInfo
  module V3
    # Simple response wrapper
    class Response
      attr_accessor :success, :data

      def initialize(success:, data:)
        @success = success
        @data = data
      end

      def success?
        @success
      end

      def exception?
        data.is_a?(StandardError)
      end

      def to_s
        exception? ? data.message : data
      end
    end
  end
end
