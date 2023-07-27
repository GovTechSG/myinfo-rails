# frozen_string_literal: true

require 'jwe'

describe MyInfo::V4::Security do
  describe '#create_code_verifier' do
    it 'creates a code verifier of the correct length' do
      code_verifier = described_class.create_code_verifier
      expect(code_verifier).not_to be_empty
    end
  end

  describe '#create_code_challenge' do
    # code_verifier test case values taken from MyInfo's code challenge generator
    let(:code_verifier) { 'U2ptdDRDMkNhYmF6MVlESTZuWXZ2dkVyMXhiVDNhZko' }
    let(:expected_code_challenge) { 'FkMwoc-HA4015MuSfEjjjPvxF0e82VxGHYP4Q8-12b4' }
    it 'returns the correct code_challenge' do
      expect(described_class.create_code_challenge(code_verifier)).to eql(expected_code_challenge)
    end
  end

  describe '#generate_jwk_thumbprint' do
    # jwk and expected_jwk_thumbprint referenced from 'https://datatracker.ietf.org/doc/html/rfc7638' (ietf's jwk is converted to pem format here)
    let(:jwk) { "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0vx7agoebGcQSuuPiLJX\nZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tS\noc/BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ/2W+5JsGY4Hc5n9yBXArwl93lqt\n7/RN5w6Cf0h4QyQ5v+65YGjQR0/FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0\nzgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt+bFTWhAI4vMQFh6WeZu0f\nM4lFd2NcRwr3XPksINHaQ+G/xBniIqbw0Ls1jF44+csFCur+kEgU8awapJzKnqDK\ngwIDAQAB\n-----END PUBLIC KEY-----"}
    let(:expected_jwk_thumbprint) { 'NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs' }
    it 'generates the correct jwk thumbprint' do
      expect(described_class.generate_jwk_thumbprint(jwk)).to eql(expected_jwk_thumbprint)
    end
  end

  describe '#decrypt_jwe' do
    let(:decrypted_text) { 'decrypted' }
    let(:private_key) { JOSE::JWK.generate_key([:ec, 'P-256']) }
    let(:private_key_pem) { JOSE::JWK.to_pem(private_key) }
    let(:public_key) { JOSE::JWK.to_public(private_key) }
    let(:encrypted_jwe) { JOSE::JWE.block_encrypt([public_key, private_key], decrypted_text, { 'alg' => 'ECDH-ES', 'enc' => 'A128GCM'}).compact }

    it 'correctly decrypts the encrypted text' do
      expect(described_class.decrypt_jwe(encrypted_jwe, private_key_pem)).to eq('decrypted')
    end
  end

  describe '#generate_client_assertion' do
    let(:url) { 'https://test.api.myinfo.gov.sg/com/v4/token' }
    let(:client_id) { 'STG2-MYINFO-SELF-TEST' }
    let(:private_signing_key) { "-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEIGcOBk0/8HtXAR8XkSinGpVE4GTmbPQnjkhGO+A+QrPaoAoGCCqGSM49AwEHoUQDQgAEBXUWq0Z2RRFqrlWbW2muIybNnj/YBxflNQTEOg+QmCS9c7gbjIOjSI5UkDOYRbIhnBfCdKcbE8itl7tJfQ8q7g==\n-----END EC PRIVATE KEY-----\n" }
    let(:jkt_thumbprint) { 'G_q8Qv9-xv_9xJo-esolTnvxVSobMER7O0LKGPBlTqY' }
    let(:kid) { 'aQPyZ72NM043E4KEioaHWzixt0owV99gC9kRK388WoQ' }

    it 'successfully creates client_assertion' do
      client_assertion = described_class.generate_client_assertion(url, client_id, private_signing_key, jkt_thumbprint, kid)
      expect(client_assertion).to_not be_empty
    end
  end
end