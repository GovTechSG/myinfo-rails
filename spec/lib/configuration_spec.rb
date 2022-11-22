# frozen_string_literal: true

describe MyInfo::Configuration do
  let(:config) { described_class.new }

  before do
    config.singpass_eservice_id = 'eservice_id'
    config.client_id = 'client_id'
    config.gateway_key = 'sample_key'
  end

  it 'should have correct attributes' do
    expect(config).not_to be_public
    expect(config).not_to be_sandbox
    expect(config.client_id).to eql('client_id')
    expect(config.gateway_key).to eql('sample_key')
    expect(config.singpass_eservice_id).to eql('eservice_id')
    expect(config.proxy[:address]).to be_nil
    expect(config.proxy[:port]).to be_nil
  end

  describe 'base_url handling' do
    context 'with https://' do
      before do
        config.base_url = 'https://test.something'
      end

      it 'should save correct base_url' do
        expect(config.base_url).to eq('test.something')
      end
    end

    context 'with https:// and extra slashes behind' do
      before do
        config.base_url = 'https://test.something/something-else'
      end

      it 'should save correct base_url' do
        expect(config.base_url).to eq('test.something')
      end
    end

    context 'without https://' do
      before do
        config.base_url = 'test.something'
      end

      it 'should save correct base_url' do
        expect(config.base_url).to eq('test.something')
      end
    end

    context 'without https:// but with extra slashes behind' do
      before do
        config.base_url = 'test.something/extra-something'
      end

      it 'should save correct base_url' do
        expect(config.base_url).to eq('test.something')
      end
    end
  end

  describe 'gateway_host handling' do
    context 'with https://' do
      before do
        config.gateway_url = 'https://test_gateway_url.something'
      end

      it 'should save correct gateway_host' do
        expect(config.gateway_host).to eq('test_gateway_url.something')
      end
    end

    context 'with https:// and extra slashes behind' do
      before do
        config.gateway_url = 'https://test_gateway_url.something/something-else'
      end

      it 'should save correct gateway_host' do
        expect(config.gateway_host).to eq('test_gateway_url.something')
      end
    end

    context 'without https://' do
      before do
        config.gateway_url = 'test_gateway_url.something'
      end

      it 'should save correct gateway_url' do
        expect(config.gateway_host).to eq('test_gateway_url.something')
      end
    end

    context 'without https:// but with extra slashes behind' do
      before do
        config.gateway_url = 'test_gateway_url.something/extra-something'
      end

      it 'should save correct gateway_host' do
        expect(config.gateway_host).to eq('test_gateway_url.something')
      end
    end
  end

  describe 'gateway_path handling' do
    context 'with gateway_url as empty' do
      before do
        config.gateway_url = ''
      end

      it 'should return gateway_path as empty' do
        expect(config.gateway_path).to eq('')
      end
    end

    context 'with a valid gateway url' do
      before do
        config.gateway_url = 'https://test_gateway_url.something/something-else'
      end

      it 'should return valid gateway_path' do
        expect(config.gateway_path).to eq('something-else')
      end
    end
  end
end
