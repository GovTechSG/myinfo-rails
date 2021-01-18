# frozen_string_literal: true

describe MyInfo do
  it 'is possible to provide configuration' do
    described_class.configure do |c|
      expect(c).to be_a(MyInfo::Configuration)
    end
  end
end
