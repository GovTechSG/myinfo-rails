# frozen_string_literal: true

module MyInfo
  module V4
    # https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v4.0.html#operation/getauthorize
    class AuthoriseUrl
      extend Callable

      attr_accessor :attributes, :code_challenge, :purpose, :nric_fin

      def initialize(purpose:, code_challenge:, nric_fin: nil, attributes: nil)
        @attributes = Attributes.parse(attributes)
        @code_challenge = code_challenge
        @purpose = purpose
        @nric_fin = nric_fin
      end

      def call
        query_string = {
          purpose_id: purpose,
          response_type: 'code',
          scope: attributes,
          code_challenge: code_challenge,
          code_challenge_method: 'S256',
          redirect_uri: config.redirect_uri,
          client_id: config.client_id
        }.compact.to_param

        endpoint(query_string)
      end

      def endpoint(query_string)
        if config.public?
          "#{config.base_url_with_protocol}/#{slug}?#{query_string}"
        else
          # TODO: update url for gov version
          "#{config.base_url_with_protocol}/#{slug}/#{nric_fin}?#{query_string}"
        end
      end

      def slug
        slug_prefix = config.public? ? 'com' : 'gov'

        "#{slug_prefix}/v4/authorize"
      end

      def config
        MyInfo.configuration
      end
    end
  end
end
