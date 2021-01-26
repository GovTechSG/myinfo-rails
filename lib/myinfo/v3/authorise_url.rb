# frozen_string_literal: true

module MyInfo
  module V3
    # https://public.cloud.myinfo.gov.sg/myinfo/tuo/myinfo-tuo-specs.html#operation/getauthorise
    class AuthoriseUrl
      extend Callable

      attr_accessor :nric_fin, :attributes, :purpose, :state

      def initialize(nric_fin:, purpose:, state:, attributes: nil)
        @nric_fin = nric_fin
        @attributes = Attributes.parse(attributes)
        @purpose = purpose
        @state = state
      end

      # TODO: validate calls
      def call
        query_string = {
          purpose: purpose,
          client_id: config.client_id,
          attributes: attributes,
          sp_esvcId: config.singpass_eservice_id,
          state: state,
          redirect_uri: config.redirect_uri
        }.to_param

        "#{config.base_url_with_protocol}/#{slug}/#{nric_fin}/?#{query_string}"
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
