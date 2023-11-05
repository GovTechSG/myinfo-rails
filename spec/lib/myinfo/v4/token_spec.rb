# frozen_string_literal: true

describe MyInfo::V4::Token do
  describe '#call' do
    subject { described_class.call(auth_code: 'somecode', code_verifier: 'verifier') }

    before do
      MyInfo.configure do |config|
        config.base_url = 'test.myinfo.endpoint'
        config.singpass_eservice_id = 'service_id'
        config.client_id = 'test_client'
        config.client_secret = 'test_secret'
        config.private_encryption_key = File.read(File.join(__dir__,
                                                            '../../../fixtures/v4/sample-encryption-private-key.pem'))
        config.private_signing_key = File.read(File.join(__dir__,
                                                         '../../../fixtures/v4/sample-signing-private-key.pem'))
        config.sandbox = false
        config.redirect_uri = 'redirect'
      end

      allow(SecurityHelper).to receive(:generate_dpop) { 'some dpop values' }
      allow(SecurityHelper).to receive(:generate_client_assertion) { 'some-client-assertion' }

      stub_request(:post, 'https://test.myinfo.endpoint/gov/v4/token').with(
        body: {
          'client_assertion' => 'some-client-assertion',
          'client_assertion_type' => 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          'client_id' => 'test_client',
          'code' => 'somecode',
          'code_verifier' => 'verifier',
          'grant_type' => 'authorization_code',
          'redirect_uri' => 'redirect'
        },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Dpop' => 'some dpop values'
        }
      ).to_return(response)
    end

    context 'when response is successful' do
      let(:response) do
        {
          body: { access_token: 'SomeJWTAccessToken' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end

      it 'should return correct data' do
        expect(subject).to be_success
        expect(subject.data).to eql('SomeJWTAccessToken')
      end
    end

    context 'unsuccessful response - 401' do
      let(:response) do
        {
          status: 400,
          body: { message: 'error', code: '401' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end

      it 'should return correct data' do
        expect(subject).not_to be_success
        expect(subject.data).to eql('401 - error')
      end
    end

    context 'unexpected response' do
      let(:response) do
        {
          status: 500,
          body: 'some unexpected message',
          headers: { 'Content-Type' => 'application/json' }
        }
      end

      it 'should return correct data' do
        expect(subject).not_to be_success
        expect(subject.data).to eql('500 - some unexpected message')
      end
    end

    context 'with exception' do
      let(:response) { {} }

      before do
        allow_any_instance_of(Net::HTTP).to receive(:request_post).and_raise(Net::ReadTimeout, 'timeout')
      end

      it 'should return a false response' do
        expect(subject).not_to be_success
        expect(subject).to be_exception
        expect(subject.data).to eql('Net::ReadTimeout with "timeout"')
      end
    end
  end
end
