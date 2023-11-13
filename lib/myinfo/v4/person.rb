# frozen_string_literal: true

require 'jwt'

module MyInfo
  module V4
    # Calls the Person API
    class Person < Api
      attr_reader :access_token, :decoded_token, :attributes, :user_identifier

      def initialize(key_pairs:, access_token:, attributes: nil)
        super(key_pairs: key_pairs)
        @access_token = access_token
        @decoded_token = verify_jws(access_token).first
        @user_identifier = @decoded_token['sub']

        @attributes = Attributes.parse(attributes, ' ')
      end

      def call
        super do
          # call person API using, uinfin, access token, ephemeral key_pairs
          headers = header(access_token: access_token).merge({ 'Content-Type' => 'application/x-www-form-urlencoded' })
          endpoint_url = "/#{api_path}?#{params.to_query}"

          response = http.request_get(endpoint_url, headers)
          parse_response(response)
        end
      end

      def slug
        slug_prefix = config.public? ? 'com' : 'gov'

        "#{slug_prefix}/v4/person/#{user_identifier}"
      end

      def endpoint
        "#{config.base_url_with_protocol}/#{slug}"
      end

      def support_gzip?
        true
      end

      def params
        {
          scope: attributes,
          subentity_id: config.subentity_id
        }.compact
      end

      def errors
        %w[401 403 404]
      end

      def parse_response(response)
        super do
          json = decrypt_jwe(response.body)
          Response.new(success: true, data: json)
        end
      end

      private

      def verify_jws(access_token)
        response = jwks_http.request_get('/.well-known/keys.json')

        jwks_hash = JSON.parse(response.body)
        jwks = JWT::JWK::Set.new(jwks_hash)
        jwks.filter! { |key| key[:use] == 'sig' }
        algorithms = jwks.map { |key| key[:alg] }.compact.uniq

        JWT.decode(access_token, nil, true, algorithms: algorithms, jwks: jwks)
      end
    end
  end
end
