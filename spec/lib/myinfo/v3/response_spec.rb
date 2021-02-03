# frozen_string_literal: true

describe MyInfo::V3::Response do
  context 'successful' do
    subject { described_class.new(success: true, data: 'some data') }

    it { expect(subject).to be_success }
    it { expect(subject.to_s).to eql('some data') }
  end
end
