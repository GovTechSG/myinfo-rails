# frozen_string_literal: true

describe MyInfo::V3::Api do
  describe 'default methods' do
    let(:api) { described_class.new }

    it { expect { api.endpoint }.to raise_error(NotImplementedError) }
    it { expect { api.params(nil) }.to raise_error(NotImplementedError) }
  end

  describe '#header' do
    before do
      MyInfo.configure do |config|
        config.sandbox = false
        config.gateway_key = 'sample_key'
      end

      allow_any_instance_of(described_class).to receive(:auth_header).and_return('stubbed')
    end

    let(:api) { described_class.new }
    let(:result) { api.header(params: { test: 'test' }) }

    it 'returns the correct Content-Type' do
      expect(result).to include({ 'Content-Type' => 'application/json' })
    end

    it 'returns correct Authorization header' do
      expect(result).to include({ 'Authorization' => 'stubbed' })
    end

    it 'returns correct Accept' do
      expect(result).to include({ 'Accept' => 'application/json' })
    end

    it 'returns correct x-api-key' do
      expect(result).to include({ 'x-api-key' => 'sample_key' })
    end
  end

  describe '#private_key' do
    let(:api) { described_class.new }

    context 'when no private_key in configuration' do
      before do
        MyInfo.configure do |config|
          config.private_key = nil
        end
      end

      it 'raises an error' do
        expect { api.send(:private_key) }.to raise_error(MyInfo::MissingConfigurationError)
      end
    end

    context 'with private_key' do
      before do
        MyInfo.configure do |config|
          config.private_key = File.read(File.join(__dir__, '../../../fixtures/v3/sample_private_key'))
        end
      end

      it 'returns an RSA instance' do
        expect(api.send(:private_key)).to be_a(OpenSSL::PKey::RSA)
      end
    end
  end

  describe '#public_key' do
    let(:api) { described_class.new }

    context 'when no public_cert in configuration' do
      before do
        MyInfo.configure do |config|
          config.public_cert = nil
        end
      end

      it 'raises an error' do
        expect { api.send(:public_key) }.to raise_error(MyInfo::MissingConfigurationError)
      end
    end

    context 'with public_cert' do
      before do
        MyInfo.configure do |config|
          config.public_cert = File.read(File.join(__dir__, '../../../fixtures/v3/sample_cert'))
        end
      end

      it 'returns an RSA instance' do
        expect(api.send(:public_key)).to be_a(OpenSSL::PKey::RSA)
      end
    end
  end

  describe '#auth_header' do
    subject { described_class.new.send(:auth_header, params: params, access_token: access_token) }

    let(:access_token) { nil }

    before do
      MyInfo.configure do |config|
        config.app_id = 'test-app'
      end

      allow(SecureRandom).to receive(:hex).and_return('nonce')
      allow_any_instance_of(described_class).to receive(:sign).and_return('signed')
    end

    # rubocop:disable Layout/LineLength
    context 'with additional params' do
      let(:params) { { 'key' => 'value' } }

      it 'returns the correct auth header' do
        expect(subject).to match(/PKI_SIGN app_id="test-app",nonce="nonce",signature_method="RS256",timestamp=".*",key="value",signature="signed"/)
      end
    end

    context 'with access_token' do
      let(:params) { {} }
      let(:access_token) { 'token' }

      it 'returns the correct auth header' do
        expect(subject).to match(/PKI_SIGN app_id="test-app",nonce="nonce",signature_method="RS256",timestamp=".*",signature="signed",Bearer token/)
      end
    end
    # rubocop:enable Layout/LineLength
  end

  describe '#decrypt_jwe' do
    let(:encrypted_text) { 'encrypted' }
    let(:decrypted_text) { '"decrypted"' }

    context 'when in sandbox mode' do
      subject { described_class.new.send(:decrypt_jwe, { 'key' => 'value' }.to_json) }

      before do
        MyInfo.configure do |config|
          config.sandbox = true
        end
      end

      it { expect(subject).to eql({ 'key' => 'value' }) }
    end

    context 'when not in sandbox mode' do
      subject { described_class.new.send(:decrypt_jwe, encrypted_text) }

      before do
        MyInfo.configure do |config|
          config.sandbox = false
        end
        allow(JWE).to receive(:decrypt).with(encrypted_text, instance_of(OpenSSL::PKey::RSA)).and_return(decrypted_text)
      end

      it { expect(subject).to eql(decrypted_text) }
    end
  end

  describe '#decode_jws' do
    subject { described_class.new.send(:decode_jws, encoded_text) }

    let(:encoded_text) { 'encoded' }

    before do
      allow(JWT).to receive(:decode).with(
        encoded_text,
        instance_of(OpenSSL::PKey::RSA),
        true,
        hash_including(algorithm: 'RS256')
      ).and_return([{ 'data' => 'test' }, { 'alg' => 'none' }])
    end

    it { expect(subject).to eql({ 'data' => 'test' }) }
  end

  describe '#sign' do
    subject { described_class.new.send(:sign, headers) }

    let(:headers) { { 'key' => 'value' } }

    before do
      MyInfo.configure do |config|
        config.base_url = 'test.host'
        config.private_key = File.read(File.join(__dir__, '../../../fixtures/v3/sample_private_key'))
      end
    end

    it 'converts the headers into query' do
      expect_any_instance_of(described_class).to receive(:to_query).with(headers)
      subject
    end

    it 'signs the appropriate base_string' do
      expect_any_instance_of(OpenSSL::PKey::RSA).to receive(:sign).with(an_instance_of(OpenSSL::Digest), 'GET&https://test.host/&key=value').and_call_original
      subject
    end

    it 'encodes it as base64' do
      expect(subject).to eql('C9vkyV0sq+dG2IbsHMkwqXKB84D8Irl7NHp1d+1O+v9InQoypb/ZdhWTeT8RMQ42qxujZKx4SE5J53/QNqYJrQ==')
    end
  end
end
