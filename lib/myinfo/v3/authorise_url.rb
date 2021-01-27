# frozen_string_literal: true

module MyInfo
  module V3
    # https://public.cloud.myinfo.gov.sg/myinfo/tuo/myinfo-tuo-specs.html#operation/getauthorise
    class AuthoriseUrl
      extend Callable

      attr_accessor :nric_fin, :attributes, :purpose, :state, :authmode, :login_type

      def initialize(purpose:, state:, nric_fin: nil, authmode: 'SINGPASS', login_type: 'SINGPASS', attributes: nil)
        @nric_fin = nric_fin
        @attributes = Attributes.parse(attributes)
        @purpose = purpose
        @authmode = authmode
        @login_type = login_type
        @state = state
      end

      def call
        query_string = {
          authmode: authmode,
          login_type: login_type,
          purpose: purpose,
          client_id: config.client_id,
          attributes: attributes,
          sp_esvcId: config.singpass_eservice_id,
          state: state,
          redirect_uri: config.redirect_uri
        }.compact.to_param

        endpoint(query_string)
      end

      def endpoint(query_string)
        if config.public?
          "#{config.base_url_with_protocol}/#{slug}/?#{query_string}"
        else
          "#{config.base_url_with_protocol}/#{slug}/#{nric_fin}/?#{query_string}"
        end
      end

      def slug
        slug_prefix = config.public? ? 'com' : 'gov'

        "#{slug_prefix}/v3/authorise"
      end

      def config
        MyInfo.configuration
      end
    end
  end
end
