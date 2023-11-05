# frozen_string_literal: true

module MyInfo
  module V4
    # Called after authorise to obtain a token for API calls
    class Token < Api
      attr_accessor :auth_code, :code_verifier

      def initialize(auth_code:, code_verifier:)
        super()
        @auth_code = auth_code
        @code_verifier = code_verifier
      end

      def call
        super do
          headers = header.merge({ 'Content-Type' => 'application/x-www-form-urlencoded' })
          response = http.request_post("/#{api_path}", params.to_param, headers)

          parse_response(response)
        end
      end

      def http_method
        'POST'
      end

      def endpoint
        "#{config.base_url_with_protocol}/#{slug}"
      end

      def slug
        slug_prefix = config.public? ? 'com' : 'gov'

        "#{slug_prefix}/v4/token"
      end

      def params
        {
          code: auth_code,
          grant_type: 'authorization_code',
          client_id: config.client_id,
          redirect_uri: config.redirect_uri,
          client_assertion: SecurityHelper.generate_client_assertion(
            config.client_id,
            endpoint,
            generate_thumbprint,
            private_signing_key
          ),
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          code_verifier: code_verifier
        }.compact
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
