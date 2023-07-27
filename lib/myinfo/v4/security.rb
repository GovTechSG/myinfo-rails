# frozen_string_literal: true

require 'securerandom'
require 'base64'
require 'digest'
require 'openssl'
require 'jwe'
require 'jwt'
require 'json/jwt'
require 'pry'
require 'jose'
require 'jose/jwe'

module MyInfo
  module V4
    class Security
      def config
        MyInfo.configuration
      end

      def get_private_key
        raise MissingConfigurationError, :private_key if config.private_key.blank?

        OpenSSL::PKey::RSA.new(config.private_key)
      end

      # done & tested
      def self.create_code_verifier
        code = SecureRandom.bytes(32)
        Base64.urlsafe_encode64(code, padding: false)
      end

      # done & tested
      def self.create_code_challenge(verifier)
        bytes = verifier.encode('US-ASCII')
        digest = Digest::SHA256.digest(bytes)
        Base64.urlsafe_encode64(digest, padding: false)
      end

      # done, not yet tested (OpenSSL version)
      def self.generate_ephemeral_keys
        key_pair = OpenSSL::PKey::EC.new("prime256v1")
        key_pair.generate_key

        private_key = key_pair.to_pem
        public_key = OpenSSL::PKey::EC.new(key_pair.public_key.group)
        public_key.public_key = key_pair.public_key
        public_key = public_key.to_pem

        { private_key: private_key, public_key: public_key }
      end

      # done, not yet tested (JOSE version)
      def self.generate_ephemeral_keys_jose
        private_key = JOSE::JWK.generate_key([:ec, "prime256v1"])
        public_key = JOSE::JWK.to_public(private_key)

        { private_key: private_key.to_pem, public_key: public_key.to_pem }
      end

      # done, not yet tested
      def get_jwks(jwks_url)
        uri = URI(jwks_url)
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          response_body = response.body
          response_data = JSON.parse(response_body)

          response_data['keys']
        else
          # TODO: Handle Error
        end
      end

      # not done
      def self.decode_jws(compact_jws, public_key)
        jwks = get_jwks(jwks_url)

        JWT.decode(jws, public_key, true, algorithm: 'ES256').first
      end

      # done & tested
      def self.decrypt_jwe(jwe, private_key)
        jwk_private_key = JOSE::JWK.from_pem(private_key)
        JOSE::JWE.block_decrypt(jwk_private_key, jwe).first
      end 

      # done & tested
      def self.generate_jwk_thumbprint(jwk)
        jwk_key = OpenSSL::PKey.read(jwk) # convert pem to OpenSSL::PKey::PKey object
        jwk = JSON::JWK.new(jwk_key)
        jwk.thumbprint('sha256')
      end

      # done & tested
      def self.generate_client_assertion(url, client_id, private_signing_key, jwk_thumbprint, kid)
        now = Time.now.to_i
        payload = {
          sub: client_id,
          jti: SecureRandom.alphanumeric(40),
          aud: url,
          iss: client_id,
          iat: now,
          exp: now + 300,
          cnf: {
            jkt: jwk_thumbprint
          }
        }

        private_key = OpenSSL::PKey.read(private_signing_key)
        headers = {
          'typ' => 'JWT',
          'kid' => kid
        }
        JWT.encode(payload, private_key, 'ES256', headers)
      end

      # not done
      def generateDPoP(url, ath, method, session_ephemeral_key_pair)
        raise NotImplementedError
      end
    end
  end
end