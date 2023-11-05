# frozen_string_literal: true

describe MyInfo::V3::Person do
  before do
    allow_any_instance_of(described_class).to receive(:decrypt_jwe).and_return('')
    allow_any_instance_of(described_class).to receive(:decode_jws).and_return({ 'sub' => 'S1234567A' })
  end

  describe 'common methods' do
    let(:api) { described_class.new(access_token: 'token', txn_no: 'txn') }

    it { expect(api.slug).to eql('gov/v3/person/S1234567A/') }
    it { expect(api.http_method).to eql('GET') }
    it { expect(api.txn_no).to eql('txn') }
    it { expect(api.nric_fin).to eql('S1234567A') }
    it { expect(api.attributes).to eql(MyInfo::Attributes::DEFAULT_VALUES.join(',')) }
  end

  describe '#api_path' do
    let(:subject) { described_class.new(access_token: 'token') }

    context 'without gateway_url' do
      it 'should return just slug' do
        expect(subject.api_path).to eql('gov/v3/person/S1234567A/')
      end
    end

    context 'with gateway_url' do
      before do
        MyInfo.configuration.gateway_url = 'https://test_gateway_url.something/something-else'
      end

      after do
        MyInfo.configuration.gateway_url = nil
      end

      it 'should return slug along with gateway path' do
        expect(subject.api_path).to eql('something-else/gov/v3/person/S1234567A/')
      end
    end
  end

  describe '#call' do
    before do
      MyInfo.configure do |config|
        config.base_url = 'test.myinfo.endpoint'
        config.client_id = 'test-client'
        config.sandbox = true
        config.singpass_eservice_id = 'service_id'
        config.public_cert = File.read(File.join(__dir__, '../../../fixtures/v3/sample_cert'))
        config.private_key = File.read(File.join(__dir__, '../../../fixtures/v3/sample_private_key'))
      end

      stub_request(:get,
                   'https://test.myinfo.endpoint/gov/v3/person/S1234567A/?' \
                   'attributes=testing,test2&client_id=test-client&sp_esvcId=service_id').to_return(response)
    end

    subject { described_class.call(access_token: 'token', attributes: %w[testing test2]) }

    context 'successful response' do
      let(:response) do
        {
          body: '',
          headers: { 'Content-Type' => 'application/json' }
        }
      end

      it 'should return the correct response' do
        expect(subject).to be_success
        expect(subject).not_to be_exception
        expect(subject.data).to eql('')
      end
    end

    context 'with exception' do
      let(:response) { {} }

      before do
        allow_any_instance_of(Net::HTTP).to receive(:request_get).and_raise(Net::ReadTimeout, 'timeout')
      end

      it 'should return a false response' do
        expect(subject).not_to be_success
        expect(subject).to be_exception
        expect(subject.data).to eql('Net::ReadTimeout with "timeout"')
      end
    end
  end
end
