# frozen_string_literal: true

describe MyInfo::Configuration do
  let(:config) { described_class.new }

  before do
    config.singpass_eservice_id = 'eservice_id'
    config.client_id = 'client_id'
  end

  it 'should have correct attributes' do
    expect(config.client_id).to eql('client_id')
    expect(config.singpass_eservice_id).to eql('eservice_id')
    expect(config.proxy[:address]).to be_nil
    expect(config.proxy[:port]).to be_nil
  end
end
