# frozen_string_literal: true

require 'digest'

module MyInfo
  module V4
    # Class to generate code_verifier and code_challenge to client application
    class Session
      extend Callable

      def call
        code_verifier = SecureRandom.hex(32)

        sha256_encoded_code_verifier = Digest::SHA256.digest code_verifier
        code_challenge = Base64.urlsafe_encode64(sha256_encoded_code_verifier)

        [code_verifier, code_challenge]
      end
    end
  end
end
