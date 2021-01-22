# frozen_string_literal: true

module MyInfo
  module V3
    # https://public.cloud.myinfo.gov.sg/myinfo/tuo/myinfo-tuo-specs.html#operation/getauthorise
    class AuthoriseUrl
      extend Callable

      attr_accessor :nric_fin, :attributes, :redirect_uri, :purpose, :state

      def initialize(nric_fin:, redirect_uri:, purpose:, state:, attributes: Api::DEFAULT_ATTRIBUTES)
        @nric_fin = nric_fin
        @attributes = attributes
        @redirect_uri = redirect_uri
        @purpose = purpose
        @state = state
      end

      # TODO: validate calls
      def call
        query_string = {
          purpose: purpose,
          client_id: config.client_id,
          attributes: attributes.join(','),
          sp_esvcId: config.singpass_eservice_id,
          state: state,
          redirect_uri: redirect_uri
        }.to_param

        "https://#{config.base_url}/#{slug}/#{nric_fin}/?#{query_string}"
      end

      def slug
        'gov/v3/authorise'
      end

      def config
        MyInfo.configuration
      end
    end
  end
end
