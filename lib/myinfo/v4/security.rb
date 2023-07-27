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

            # not yet tested
            def self.generate_ephemeral_keys
                key_pair = OpenSSL::PKey::EC.new("prime256v1")
                key_pair.generate_key
              
                private_key = key_pair.to_pem
                public_key = OpenSSL::PKey::EC.new(key_pair.public_key.group)
                public_key.public_key = key_pair.public_key
                public_key = public_key.to_pem
              
                { private_key: private_key, public_key: public_key }
            end

            def self.generate_ephemeral_keys_jose
                private_key = JOSE::JWK.generate_key([:ec, "prime256v1"])
                public_key = JOSE::JWK.to_public(private_key)
                
                { private_key: private_key.to_pem, public_key: public_key.to_pem }
            end

            # not yet tested
            def get_jwks(jwks_url)
                uri = URI(jwks_url)
                response = Net::HTTP.get_response(uri)

                if response.is_a?(Net::HTTPSuccess)
                    response_body = response.body
                    response_data = JSON.parse(response_body)

                    response_data['keys']
                else 
                    # Todo: Handle Error
                end
            end

            def self.decode_jws(compact_jws, public_key)
                JWT.decode(jws, public_key, true, algorithm: 'ES256').first
            end
            
            def decrypt_jwe_with_key(compact_jwe, decryption_private_key)
                jwe_parts = compact_jwe.split('.') # header.encryptedKey.iv.ciphertext.tag
                raise 'Invalid data or signature' if jwe_parts.length != 5
                
                # Session encryption private key should correspond to the session encryption public key passed in to client assertion
                key = JOSE::JWK.from_pem(decryption_private_key)
                
                data = {
                    'type' => 'compact',
                    'protected' => jwe_parts[0],
                    'encrypted_key' => jwe_parts[1],
                    'iv' => jwe_parts[2],
                    'ciphertext' => jwe_parts[3],
                    'tag' => jwe_parts[4],
                    'header' => JSON.parse(JOSE::Util.base64url_decode(jwe_parts[0]).to_s)
                }
                
                jwe = JOSE::JWE.from_serialized_compact(data.to_json)
                result = jwe.decrypt(key)
                
                result.payload.to_s
            rescue => error
            'Error decrypting JWE'
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

                jwt_token = JWT.encode(payload, private_key, 'ES256', headers)

                jwt_token
            end

            def generateDPoP(url, ath, method, session_ephemeral_key_pair)
                raise NotImplementedError
            end
        end
    end
end