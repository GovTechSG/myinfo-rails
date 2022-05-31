# frozen_string_literal: true

describe MyInfo::Configuration do
  let(:config) { described_class.new }

  before do
    config.singpass_eservice_id = 'eservice_id'
    config.client_id = 'client_id'
  end

  it 'should have correct attributes' do
    expect(config).not_to be_public
    expect(config).not_to be_sandbox
    expect(config.client_id).to eql('client_id')
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
end
