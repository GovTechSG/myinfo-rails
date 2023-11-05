# frozen_string_literal: true

module MyInfo
  module V4
    # Simple response wrapper
    class Response
      attr_reader :data

      def initialize(success:, data:)
        @success = success

        if data.is_a?(StandardError)
          @data = data.message
          @exception = true
        else
          @data = data
          @exception = false
        end
      end

      def exception?
        @exception
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
