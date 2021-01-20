# frozen_string_literal: true

describe MyInfo::V3::Api do
  describe 'default methods' do
    let(:api) { described_class.new }

    it { expect { api.endpoint }.to raise_error(NotImplementedError) }
    it { expect { api.params(nil) }.to raise_error(NotImplementedError) }
    it { expect(api.support_gzip?).to be(false) }
  end

  describe '#header' do
    before do
      MyInfo.configure { ; }
      allow_any_instance_of(described_class).to receive(:auth_header).and_return('stubbed')
    end

    let(:api) { described_class.new }
    let(:result) { api.header(params: { test: 'test' }) }

    it 'should return the correct Content-Type' do
      expect(result).to include({ 'Content-Type' => 'application/json' })
    end

    it 'should return correct Authorization header' do
      expect(result).to include({ 'Authorization' => 'stubbed' })
    end

    it 'should return correct Accept' do
      expect(result).to include({ 'Accept' => 'application/json' })
    end

    it 'should return no Content-Encoding by default' do
      expect(result.keys).not_to include('Content-Encoding')
    end
  end

  describe '#private_key' do
    let(:api) { described_class.new }

    context 'no private_key in configuration' do
      before do
        MyInfo.configure do |config|
          config.private_key = nil
        end
      end

      it 'should raise an error' do
        expect { api.send(:private_key) }.to raise_error(MyInfo::MissingConfigurationError)
      end
    end

    context 'with private_key' do
      before do
        MyInfo.configure do |config|
          config.private_key = File.read(File.join(__dir__, '../../../fixtures/sample_private_key'))
        end
      end

      it 'should return an RSA instance' do
        expect(api.send(:private_key)).to be_a(OpenSSL::PKey::RSA)
      end
    end
  end

  describe '#public_key' do
    let(:api) { described_class.new }

    context 'no public_cert in configuration' do
      before do
        MyInfo.configure do |config|
          config.public_cert = nil
        end
      end

      it 'should raise an error' do
        expect { api.send(:public_key) }.to raise_error(MyInfo::MissingConfigurationError)
      end
    end

    context 'with public_cert' do
      before do
        MyInfo.configure do |config|
          config.public_cert = File.read(File.join(__dir__, '../../../fixtures/sample_cert'))
        end
      end

      it 'should return an RSA instance' do
        expect(api.send(:public_key)).to be_a(OpenSSL::PKey::RSA)
      end
    end
  end
end
