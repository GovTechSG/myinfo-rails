# frozen_string_literal: true

module MyInfo
  module V3
    # Calls the Person API
    class Person < Api
      attr_accessor :access_token, :decoded_token, :attributes, :txn_no

      def initialize(access_token:, txn_no: nil, attributes: nil)
        @access_token = access_token
        @decoded_token = decode_jws(access_token)
        @attributes = Attributes.parse(attributes)
        @txn_no = txn_no
      end

      def call
        super do
          headers = header(params: params, access_token: access_token)
          endpoint_url = "/#{api_path}?#{params.to_query}"

          response = http.request_get(endpoint_url, headers)
          parse_response(response)
        end
      end

      def slug
        slug_prefix = config.public? ? 'com' : 'gov'

        "#{slug_prefix}/v3/person/#{nric_fin}/"
      end

      def support_gzip?
        true
      end

      def params
        {
          txnNo: txn_no,
          attributes: attributes,
          client_id: config.client_id,
          sp_esvcId: config.singpass_eservice_id
        }.compact
      end

      def nric_fin
        @nric_fin ||= decoded_token['sub']
      end

      def errors
        %w[401 403 404]
      end

      def parse_response(response)
        super do
          json = decrypt_jwe(response.body)
          json = decode_jws(json.delete('"')) unless config.sandbox?

          Response.new(success: true, data: json)
        end
      end
    end
  end
end
