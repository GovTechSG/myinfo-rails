# frozen_string_literal: true

describe MyInfo::V3::Response do
  context 'when successful' do
    subject { described_class.new(success: true, data: 'some data') }

    it { expect(subject).to be_success }
    it { expect(subject).not_to be_exception }
    it { expect(subject.to_s).to eql('some data') }
  end

  context 'when exception' do
    subject { described_class.new(success: false, data: StandardError.new('test')) }

    it { expect(subject).to be_exception }
    it { expect(subject.data).to eql('test') }
  end
end
