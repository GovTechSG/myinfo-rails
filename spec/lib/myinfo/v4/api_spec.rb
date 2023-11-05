# frozen_string_literal: true

describe MyInfo::V4::Api do
  describe 'default methods' do
    let(:api) { described_class.new }

    it { expect { api.endpoint }.to raise_error(NotImplementedError) }
    it { expect { api.params(nil) }.to raise_error(NotImplementedError) }
  end
end
