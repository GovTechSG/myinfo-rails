# frozen_string_literal: true

describe MyInfo::V4::Security do

    describe '#create_code_verifier' do
        it 'creates a code verifier of the correct length' do
            code_verifier = described_class.create_code_verifier
            expect(code_verifier).not_to be_empty
        end
    end

    describe '#create_code_challenge' do 
        let(:code_verifier) { 'U2ptdDRDMkNhYmF6MVlESTZuWXZ2dkVyMXhiVDNhZko' }

        it 'returns the correct code_challenge' do
            expect(described_class.create_code_challenge(code_verifier)).to eql('FkMwoc-HA4015MuSfEjjjPvxF0e82VxGHYP4Q8-12b4')
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