# frozen_string_literal: true

describe MyInfo::V4::AuthoriseUrl do
  before do
    MyInfo.configure do |config|
      config.base_url = 'test.endpoint'
      config.client_id = 'client'
      config.singpass_eservice_id = 'singpass'
      config.redirect_uri = 'https://app.host'
    end
  end

  context 'when public_facing = false' do
    subject do
      described_class.call(nric_fin: 'S1234567A', attributes: %w[name job],
                           purpose: 'to test', code_challenge: 'somecode')
    end

    it 'should return the correct url' do
      expect(subject).to eql(
        'https://test.endpoint/gov/v4/authorize/S1234567A' \
        '?client_id=client' \
        '&code_challenge=somecode' \
        '&code_challenge_method=S256' \
        '&purpose_id=to+test' \
        '&redirect_uri=https%3A%2F%2Fapp.host' \
        '&response_type=code' \
        '&scope=name%2Cjob'
      )
    end
  end

  context 'when configuration is public' do
    before do
      MyInfo.configuration.public_facing = true
    end

    after do
      MyInfo.configuration.public_facing = false
    end

    subject do
      described_class.call(nric_fin: 'S1234567A', attributes: %w[name job],
                           purpose: 'to test', code_challenge: 'somecode')
    end

    it 'should return the correct url' do
      expect(subject).to eql(
        'https://test.endpoint/com/v4/authorize' \
        '?client_id=client' \
        '&code_challenge=somecode' \
        '&code_challenge_method=S256' \
        '&purpose_id=to+test' \
        '&redirect_uri=https%3A%2F%2Fapp.host' \
        '&response_type=code' \
        '&scope=name%2Cjob'
      )
    end
  end
end
