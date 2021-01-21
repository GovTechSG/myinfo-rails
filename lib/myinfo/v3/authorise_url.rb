# frozen_string_literal: true

module MyInfo
  module V3
    # https://public.cloud.myinfo.gov.sg/myinfo/tuo/myinfo-tuo-specs.html#operation/getauthorise
    class AuthoriseUrl
      extend Callable

      attr_accessor :nric_fin, :attributes, :redirect_uri, :purpose, :state, :auth_mode

      def initialize(nric_fin:, attributes:, redirect_uri:, purpose:, state:, auth_mode: 'SINGPASS')
        @nric_fin = nric_fin
        @attributes = attributes
        @redirect_uri = redirect_uri
        @purpose = purpose
        @state = state
        @auth_mode = auth_mode
      end

      # TODO: validate calls
      def call
        query_string = {
          authmode: auth_mode,
          purpose: purpose,
          client_id: config.client_id,
          attributes: attributes.join(','),
          sp_esvcId: config.singpass_eservice_id,
          state: state,
          redirect_uri: redirect_uri
        }.to_param

        "#{config.base_url}/gov/v3/authorise/#{nric_fin}/?#{query_string}"
      end

      def config
        MyInfo.configuration
      end
    end
  end
end
