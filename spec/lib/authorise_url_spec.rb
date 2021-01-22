# frozen_string_literal: true

describe MyInfo::V3::AuthoriseUrl do
  before do
    MyInfo.configure do |config|
      config.base_url = 'test.endpoint'
      config.client_id = 'client'
      config.singpass_eservice_id = 'singpass'
    end
  end

  context 'correct parameters' do
    subject do
      described_class.call(nric_fin: 'S1234567A', attributes: %w[name job], redirect_uri: 'https://app.host',
                           purpose: 'to test', state: 'some state')
    end

    it 'should return the correct url' do
      expect(subject).to eql(
        'https://test.endpoint/gov/v3/authorise/S1234567A/' \
        '?attributes=name%2Cjob' \
        '&client_id=client' \
        '&purpose=to+test' \
        '&redirect_uri=https%3A%2F%2Fapp.host' \
        '&sp_esvcId=singpass' \
        '&state=some+state'
      )
    end
  end
end
