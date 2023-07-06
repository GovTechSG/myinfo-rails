# frozen_string_literal: true

require 'securerandom'
require 'base64'
require 'digest'
require 'openssl'
require 'jwt'

module MyInfo
    module V4
        class Security
            def self.create_code_verifier 
                code = SecureRandom.bytes(32)
                Base64.urlsafe_encode64(code, padding: false)
            end

            def self.create_code_challenge(verifier)
                bytes = verifier.encode('US-ASCII')
                digest = Digest::SHA256.digest(bytes)
                Base64.urlsafe_encode64(digest, padding: false)
            end

            def self.generate_ephemeral_keys
                key_pair = OpenSSL::PKey::EC.new("prime256v1")
                key_pair.generate_key
              
                private_key = key_pair.to_pem
                public_key = OpenSSL::PKey::EC.new(key_pair.public_key.group)
                public_key.public_key = key_pair.public_key
                public_key = public_key.to_pem
              
                { private_key: private_key, public_key: public_key }
            end

            def get_jwks(jwks_url)
                raise NotImplementedError
            end

            def verify_jws(compact_jws, jwks_url)
                raise NotImplementedError
            end

            def decrypt_jwe(compact_jwe, decryption_private_key)
                raise NotImplementedError
            end

            def self.generate_jwk_thumbprint(jwk)
                jwk_key = OpenSSL::PKey::RSA.new(jwk)
                jwk_thumbprint = Digest::SHA256.digest(jwk_key.public_key.to_der)
                jwk_thumbprint_encoded = Base64.urlsafe_encode64(jk_thumbprint)

                jwk_thumbprint_encoded
            end

            def self.generate_client_assertion(url, client_id, private_signing_key, jkt_thumbprint, kid)
                now = Time.now.to_i
                payload = {
                    sub: client_id,
                    jti: SecureRandom.alphanumeric(40),
                    aud: url,
                    iss: client_id,
                    iat: now,
                    exp: now + 300,
                    cnf: {
                        jkt: jkt_thumbprint
                    }
                }

                private_key = OpenSSL::PKey.read(private_signing_key)
                headers = {
                    'typ' => 'JWT',
                    'kid' => kid
                }

                jwt_token = JWT.encode(payload, private_key, 'RS256', headers)

                jwt_token
            end

            def generateDPoP(url, ath, method, session_ephemeral_key_pair)
                raise NotImplementedError
            end
        end
    end
end