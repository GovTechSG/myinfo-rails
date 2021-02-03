# frozen_string_literal: true

module MyInfo
  module V3
    # Called after authorise to obtain a token for API calls
    class Token < Api
      attr_accessor :code, :state

      def initialize(code:, state: nil)
        @code = code
        @state = state
      end

      def call
        super do
          headers = header(params: params).merge({ 'Content-Type' => 'application/x-www-form-urlencoded' })
          response = http.request_post("/#{slug}", params.to_param, headers)

          parse_response(response)
        end
      end

      def http_method
        'POST'
      end

      def slug
        slug_prefix = config.public? ? 'com' : 'gov'

        "#{slug_prefix}/v3/token"
      end

      def params
        {
          code: code,
          state: state,
          client_id: config.client_id,
          client_secret: config.client_secret,
          grant_type: 'authorization_code',
          redirect_uri: config.redirect_uri
        }.compact
      end

      def errors
        %w[400 401]
      end

      def parse_response(response)
        super do
          json = JSON.parse(response.body)
          access_token = json['access_token']

          Response.new(success: true, data: access_token)
        end
      end
    end
  end
end
