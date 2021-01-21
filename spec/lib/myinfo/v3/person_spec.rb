# frozen_string_literal: true

describe MyInfo::V3::Person do
  before do
    allow_any_instance_of(described_class).to receive(:decrypt_jwe).and_return('')
    allow_any_instance_of(described_class).to receive(:decode_jws).and_return({ 'sub' => 'S1234567A' })
  end

  describe 'common methods' do
    let(:api) { described_class.new(access_token: 'token', txn_no: 'txn') }

    it { expect(api.slug).to eql('gov/v3/person') }
    it { expect(api.http_method).to eql('GET') }
    it { expect(api.txn_no).to eql('txn') }
    it { expect(api.nric_fin).to eql('S1234567A') }
    it { expect(api.attributes).to eql(described_class::DEFAULT_ATTRIBUTES) }
  end

  describe '#call' do
    before do
      MyInfo.configure do |config|
        config.base_url = 'test.myinfo.endpoint'
        config.client_id = 'test-client'
        config.singpass_eservice_id = 'service_id'
        config.public_cert = File.read(File.join(__dir__, '../../../fixtures/sample_cert'))
        config.private_key = File.read(File.join(__dir__, '../../../fixtures/sample_private_key'))
      end

      stub_request(:get,
                   'https://test.myinfo.endpoint:80/gov/v3/person/S1234567A/?' \
                   'attributes=testing,test2&client_id=test-client&sp_esvcId=service_id'
      ).to_return(response)
    end

    context 'successful response' do
      let(:response) do
        {
          body: '',
          headers: { 'Content-Type' => 'application/json' }
        }
      end

      subject { described_class.call(access_token: 'token', attributes: %w[testing test2]) }

      it 'should return the correct response' do
        expect(subject).to eql({ success: true, data: '' })
      end
    end
  end
end
