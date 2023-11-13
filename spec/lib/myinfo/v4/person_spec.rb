# frozen_string_literal: true

describe MyInfo::V4::Person do
  before do
    MyInfo.configure do |config|
      config.public_facing = public_facing
      config.base_url = 'test.myinfo.endpoint'
      config.authorise_jwks_base_url = 'test.authorise.singpass.gov.sg'
    end

    allow(SecurityHelper).to receive(:thumbprint).with('public').and_return('thumbprint')
    allow(SecurityHelper).to receive(:generate_dpop) { 'some dpop values' }
    allow(SecurityHelper).to receive(:generate_client_assertion) { 'some-client-assertion' }

    allow(JWT).to receive(:decode).and_return([{ 'sub' => '9E9B2260-47B8-455B-89B5-C48F4DB98322' }])

    # rubocop:disable Layout/LineLength
    stub_request(:get, 'https://test.authorise.singpass.gov.sg/.well-known/keys.json')
      .to_return(body: '{
  "keys": [
    {
      "alg": "RS256",
      "use": "sig",
      "kty": "RSA",
      "kid": "_RC6xwOMvbtt6ajWuZe6Glgs-j3wm5riAyCUoRasa-I",
      "x5t": "tsPLUcV212j_gO4vY-2pUI9CHhw",
      "n": "sGBNIs4nsiHNfLqoR40h06We1IvWVaGISvETHKlJATWIURd9wx1bqHZ6tesVmLYqKT776kgxXwVD8NP0Vu-Th8C-IF-9fMNOa8_TeowvcqDiIRjL7RId8kmpcmjtIS2G-MolfSbH7CRWVRko4q88LMbJUAlglSnFppfQhsEVYlwLtZlHAYy9cl8PcsxPmFUzCUH4Fefyq77BBUPMpzbZLLjlAj97rF1oSQJKHM6RBLcvI-AauRpKe34O3GR9bCCTbkhETVerWsemtFUznr9moOSaDkEMIGA5wDyt12kjKKvbbm-k2Y5TMq1IIQXfhihGAbTttVpmZLYwJda0nemL4Q",
      "e": "AQAB"
    },
    {
      "alg": "ES256",
      "use": "sig",
      "kty": "EC",
      "kid": "AFMnnKRWTaBYEhNfEB6iQ5ErC1yqGVyZchH8A7nl_yM",
      "crv": "P-256",
      "x": "L_GG9F-hIWXxUEWCB4Fco6zXJkbaU_aUMSbHVbwEwso",
      "y": "lNPEj7SHn5IFsO76Xel13d3NDlql8JyToZFylm5V-kU"
    },
    {
      "alg": "ECDH-ES+A256KW",
      "use": "enc",
      "kty": "EC",
      "kid": "M-JXqh0gh1GGUUdzNue3IUDyUiagqjHathnscUk2nS8",
      "crv": "P-256",
      "x": "qrR8PAUO6fDouV-6mVdix5IyrVMtu0PVS0nOqWBZosA",
      "y": "6xSbySYW6ke2V727TCgSOPiH4XSDgxFCUrAAMSbl9tI"
    }
  ]
}')
    # rubocop:enable Layout/LineLength
  end

  let(:key_pairs) do
    { private_key: 'private', public_key: 'public' }
  end
  let(:access_token) { 'access_token' }

  describe 'common methods' do
    let(:api) { described_class.new(key_pairs: key_pairs, access_token: access_token, attributes: 'test') }
    let(:public_facing) { true }

    it { expect(api.http_method).to eql('GET') }
    it { expect(api.attributes).to eql('test') }

    context 'when config is public' do
      let(:public_facing) { true }

      it { expect(api.slug).to eql('com/v4/person/9E9B2260-47B8-455B-89B5-C48F4DB98322') }
    end

    context 'when config is not public' do
      let(:public_facing) { false }

      it { expect(api.slug).to eql('gov/v4/person/9E9B2260-47B8-455B-89B5-C48F4DB98322') }
    end
  end

  describe '#call' do
    subject do
      described_class.call(key_pairs: key_pairs,
                           access_token: access_token,
                           attributes: %i[name sex race dob])
    end

    context 'when public_facing is `true` and request is successful' do
      let(:public_facing) { true }

      before do
        stub_request(:get, 'https://test.myinfo.endpoint/com/v4/person/9E9B2260-47B8-455B-89B5-C48F4DB98322?scope=name%20sex%20race%20dob')
          .to_return(status: 200, body: '', headers: {'Content-Type' => 'application/json'} )

        allow_any_instance_of(described_class).to receive(:decrypt_jwe).and_return({})
      end

      it 'should return a true response' do
        expect(subject).to be_success
        expect(subject).not_to be_exception
        expect(subject.data).to eql({})
      end
    end
  end
end
