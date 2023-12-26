# frozen_string_literal: true

require 'jwt'

module MyInfo
  module V4
    # Base API class
    class Api
      extend Callable

      attr_reader :key_pairs, :thumbprint

      def initialize(key_pairs:)
        @key_pairs = key_pairs
        @thumbprint = SecurityHelper.thumbprint(key_pairs[:public_key])
      end

      def endpoint
        raise NotImplementedError, 'abstract'
      end

      def params(_args)
        raise NotImplementedError, 'abstract'
      end

      def slug
        ''
      end

      def call
        yield
      rescue StandardError => e
        Response.new(success: false, data: e)
      end

      def http_method
        'GET'
      end

      def support_gzip?
        false
      end

      def header(access_token: nil) # rubocop:disable Metrics/AbcSize
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cache-Control' => 'no-cache'
        }.tap do |values|
          values['x-api-key'] = config.gateway_key if config.gateway_key.present?

          unless config.sandbox?
            values['Authorization'] = auth_header(access_token: access_token) if access_token.present?
            values['dpop'] = SecurityHelper.generate_dpop(endpoint, access_token, http_method, key_pairs)
          end

          if support_gzip?
            values['Accept-Encoding'] = 'gzip'
            values['Content-Encoding'] = 'gzip'
          end
        end
      end

      def api_path
        path = config.gateway_path.present? ? "#{config.gateway_path}/" : ''
        "#{path}#{slug}"
      end

      def parse_response(response)
        if response.code == '200'
          yield
        elsif errors.include?(response.code)
          json = JSON.parse(response.body)

          Response.new(success: false, data: "#{json['code']} - #{json['message']}")
        else
          Response.new(success: false, data: "#{response.code} - #{response.body}")
        end
      end

      protected

      def http
        url = config.gateway_host || config.base_url
        @http ||= if config.proxy.blank?
                    Net::HTTP.new(url, 443)
                  else
                    Net::HTTP.new(url, 443, config.proxy[:address], config.proxy[:port])
                  end

        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        @http
      end

      def jwks_http
        url = config.gateway_host || config.authorise_jwks_base_url
        @jwks_http_client = if config.proxy.blank?
                              Net::HTTP.new(url, 443)
                            else
                              Net::HTTP.new(url, 443, config.proxy[:address], config.proxy[:port])
                            end

        @jwks_http_client.use_ssl = true
        @jwks_http_client.verify_mode = OpenSSL::SSL::VERIFY_PEER

        @jwks_http_client
      end

      def config
        MyInfo.configuration
      end

      def errors
        %w[400 401]
      end

      private

      def private_encryption_key
        raise MissingConfigurationError, :private_encryption_key if config.private_encryption_key.blank?

        OpenSSL::PKey::EC.new(config.private_encryption_key)
      end

      def private_signing_key
        raise MissingConfigurationError, :private_signing_key if config.private_signing_key.blank?

        OpenSSL::PKey::EC.new(config.private_signing_key)
      end

      def to_query(headers)
        headers.sort_by { |k, v| [k.to_s, v] }
               .map { |arr| arr.join('=') }
               .join('&')
      end

      def auth_header(access_token: nil)
        "DPoP #{access_token}"
      end
    end
  end
end
