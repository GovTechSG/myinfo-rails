# frozen_string_literal: true

require 'jwe'
require 'jwt'

module MyInfo
  module V3
    # Base API class
    class Api
      extend Callable

      def endpoint
        raise NotImplementedError, 'abstract'
      end

      def params(_args)
        raise NotImplementedError, 'abstract'
      end

      def call
        yield
      rescue StandardError => e
        Response.new(success: false, data: e)
      end

      def slug
        ''
      end

      def http_method
        'GET'
      end

      def support_gzip?
        false
      end

      def header(params:, access_token: nil)
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cache-Control' => 'no-cache'
        }.tap do |values|
          values['Authorization'] = auth_header(params: params, access_token: access_token) unless config.sandbox?

          if support_gzip?
            values['Accept-Encoding'] = 'gzip'
            values['Content-Encoding'] = 'gzip'
          end
        end
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

      def decrypt_jwe(text)
        if config.sandbox?
          JSON.parse(text)
        else
          JWE.decrypt(text, private_key)
        end
      end

      def decode_jws(jws)
        JWT.decode(jws, public_key, true, algorithm: 'RS256').first
      end

      def http
        @http ||= if config.proxy.blank?
                    Net::HTTP.new(config.base_url, 443)
                  else
                    Net::HTTP.new(config.base_url, 443, config.proxy[:address], config.proxy[:port])
                  end

        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        @http
      end

      def config
        MyInfo.configuration
      end

      private

      def private_key
        raise MissingConfigurationError, :private_key if config.private_key.blank?

        OpenSSL::PKey::RSA.new(config.private_key)
      end

      def public_key
        raise MissingConfigurationError, :public_cert if config.public_cert.blank?

        OpenSSL::X509::Certificate.new(config.public_cert).public_key
      end

      def to_query(headers)
        headers.sort_by { |k, v| [k.to_s, v] }
               .map { |arr| arr.join('=') }
               .join('&')
      end

      def auth_header(params:, access_token: nil)
        auth_headers = {
          app_id: config.app_id,
          nonce: SecureRandom.hex,
          signature_method: 'RS256',
          timestamp: (Time.now.to_f * 1000).to_i
        }.merge(params)

        auth_headers[:signature] = sign(auth_headers)

        header_elements = auth_headers.map { |k, v| "#{k}=\"#{v}\"" }
        header_elements << "Bearer #{access_token}" if access_token.present?

        "PKI_SIGN #{header_elements.join(',')}"
      end

      def sign(headers)
        headers_query = to_query(headers)
        base_string = "#{http_method}&#{config.base_url_with_protocol}/#{slug}&#{headers_query}"
        signed_string = private_key.sign(OpenSSL::Digest.new('SHA256'), base_string)
        Base64.strict_encode64(signed_string)
      end
    end
  end
end
