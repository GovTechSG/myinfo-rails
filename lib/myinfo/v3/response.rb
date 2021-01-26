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

      def to_s
        data
      end
    end
  end
end
