# frozen_string_literal: true

require 'jwe'
require 'jwt'

# Helper class for security related codes
class SecurityHelper
  class << self
    def generate_session_key_pair
      ec = OpenSSL::PKey::EC.generate('prime256v1')

      group = ec.public_key.group
      point = ec.public_key
      asn1 = OpenSSL::ASN1::Sequence(
        [
          OpenSSL::ASN1::Sequence([
                                    OpenSSL::ASN1::ObjectId('id-ecPublicKey'),
                                    OpenSSL::ASN1::ObjectId(group.curve_name)
                                  ]),
          OpenSSL::ASN1::BitString(point.to_octet_string(:uncompressed))
        ]
      )
      public_key = OpenSSL::PKey::EC.new(asn1.to_der)

      { private_key: ec.to_pem, public_key: public_key.to_pem }
    end

    def generate_dpop(url, access_token, http_method, key_pairs)
      now = Time.now.to_i
      payload = {
        htu: url,
        htm: http_method,
        jti: SecureRandom.alphanumeric(40),
        iat: now,
        exp: now + 120
      }

      payload[:ath] = access_token if access_token.present?

      private_key = OpenSSL::PKey.read(key_pairs[:private_key])
      jwk = OpenSSL::PKey.read(key_pairs[:public_key])

      headers = {
        'typ' => 'dpop+jwt',
        'jwk' => jwk
      }
      JWT.encode(payload, private_key, 'ES256', headers)
    end

    def generate_client_assertion(client_id, url, thumbprint, private_signing_key)
      now = Time.now.to_i
      payload = {
        sub: client_id,
        jti: SecureRandom.alphanumeric(40),
        aud: url,
        iss: client_id,
        iat: now,
        exp: now + 300,
        cnf: {
          jkt: thumbprint
        }
      }

      headers = {
        'typ' => 'JWT'
      }

      JWT.encode(payload, private_signing_key, 'ES256', headers)
    end
  end
end
