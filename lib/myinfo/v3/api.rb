# frozen_string_literal: true

require 'jwe'
require 'jwt'

module MyInfo
  module V3
    # Base API class
    class Api
      extend Callable

      DEFAULT_ATTRIBUTES = %i[name sex race dob residentialstatus email mobileno regadd].freeze

      def endpoint
        raise NotImplementedError, 'abstract'
      end

      def params(_args)
        raise NotImplementedError, 'abstract'
      end

      def http_method
        'GET'
      end

      def header(params:, access_token: nil)
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cache-Control' => 'no-cache',
          'Accept-Encoding' => 'gzip',
          'Content-Encoding' => 'gzip'
        }.tap do |values|
          values['Authorization'] = auth_header(params: params, access_token: access_token) unless config.sandbox?
        end
      end

      def authorise_params(attributes, **kwargs)
        {
          authmode: 'SINGPASS',
          login_type: 'SINGPASS',
          response_type: 'code',
          attributes: attributes.join(','),
          client_id: config.client_id
        }.merge(kwargs).compact
      end

      def parse_response(response)
        if response.code == '200'
          yield
        elsif errors.include?(response.code)
          json = JSON.parse(response.body)

          { success: false, data: "#{json['code']} - #{json['message']}" }
        else
          { success: false, data: "#{response.code} - #{response.body}" }
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
        # TODO: verify signature
        JWT.decode(jws, public_key, true, algorithm: 'RS256').first
      end

      def http
        @http ||= if config.proxy.blank?
                    Net::HTTP.new(config.base_url)
                  else
                    Net::HTTP.new(config.base_url, nil, config.proxy[:address], config.proxy[:port])
                  end

        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        @http
      end

      def config
        MyInfo.configuration
      end

      def call
        yield
      rescue StandardError => e
        { success: false, data: "#{e.class} - #{e.message}" }
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

      def sign(params)
        query_string = params.to_query
        base_string = "#{http_method}&#{config.base_url}&#{query_string}"
        signed_string = private_key.sign(OpenSSL::Digest.new('SHA256'), base_string)
        Base64.strict_encode64(signed_string)
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
    end
  end
end
