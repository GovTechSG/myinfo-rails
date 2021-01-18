# frozen_string_literal: true

module MyInfo
  module V3
    # Base API class
    class Api
      def self.call(**kwargs)
        new(**kwargs).call
      end

      def endpoint
        raise NotImplementedError, 'abstract'
      end

      def params(_args)
        raise NotImplementedError, 'abstract'
      end

      def support_gzip?
        false
      end

      def http_method
        'GET'
      end

      def header(params:, access_token: nil)
        {
          'Content-Type' => 'application/json',
          'Authorization' => auth_header(params: params, access_token: access_token),
          'Accept' => 'application/json',
          'Cache-Control' => 'no-cache'
        }.tap do |values|
          values['Content-Encoding'] = 'gzip' if support_gzip?
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

      protected

      def decrypt_jwe(text)
        if config.encrypted
          JWE.decrypt(text, private_key)
        else
          JSON.parse(text)
        end
      end

      def decode_jws(jws)
        if config.encrypted
          JWT.decode(jws, public_key, true, algorithm: 'RS256')
        else
          jws
        end
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
        query_string = params.sort_by { |k, v| [k.to_s, v] }
                             .map { |arr| arr.join('=') }
                             .join('&')

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
