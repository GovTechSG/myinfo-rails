# frozen_string_literal: true

describe MyInfo::V4::Session do
  describe '#call' do
    it 'generates code verifier and code challenge', :aggregate_failures do
      allow(SecureRandom).to receive(:hex) { '1ee2add6ca7205e61269830220f3ab5243ae861283ed06f0fb47f65a57e43544' }

      code_verifier, code_challenge = described_class.call

      expect(code_verifier).to eq('1ee2add6ca7205e61269830220f3ab5243ae861283ed06f0fb47f65a57e43544')
      expect(code_challenge).to eq('DtrKdNTEchv8SF7IUjlKHfDP3i40vuw_6VMS8eqvkEQ=')
    end
  end
end
