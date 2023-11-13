# frozen_string_literal: true

describe MyInfo::V4::Api do
  describe 'default methods' do
    let(:api) { described_class.new(key_pairs: { private_key: 'private', public_key: 'public' }) }

    before do
      allow(SecurityHelper).to receive(:thumbprint).with('public').and_return('thumbprint')
    end

    it { expect { api.endpoint }.to raise_error(NotImplementedError) }
    it { expect { api.params(nil) }.to raise_error(NotImplementedError) }
  end
end
