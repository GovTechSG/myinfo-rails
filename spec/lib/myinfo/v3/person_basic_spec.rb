# frozen_string_literal: true

describe MyInfo::V3::PersonBasic do
  describe 'common methods' do
    let(:api) { described_class.new(nric_fin: 'S1234567A') }

    it { expect(api.slug).to eql('person-basic') }
    it { expect(api.http_method).to eql('GET') }
    it { expect(api.gzip_support?).to be(true) }
    it { expect(api.nonce).not_to be_nil }
    it { expect(api.txn_no).not_to be_nil }
    it { expect(api.nric_fin).to eql('S1234567A') }
    it { expect(api.attributes).to eql(described_class::DEFAULT_ATTRIBUTES) }
  end

  describe '#call' do
    before do
      MyInfo.configure do |config|
        config.base_url = 'test.myinfo.endpoint'
        config.singpass_eservice_id = 'service_id'
        config.private_key = File.read(File.join(__dir__, '../../../fixtures/sample_private_key'))
        config.proxy = {
          address: 'https://some.proxy',
          port: 8080
        }
      end

      # TODO: Patch webmock to allow proxy check
      stub_request(:get,
                   Regexp.new(
                     "#{Regexp.escape('https://test.myinfo.endpoint:80/person-basic/S1234567A?')}.*"
                   ))
    end

    it 'should call the correct endpoint' do
      expect_any_instance_of(Net::HTTP).to receive(:request_get).and_call_original
      described_class.call(nric_fin: 'S1234567A')
    end
  end
end
