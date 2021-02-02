# frozen_string_literal: true

module MyInfo
  module V3
    # Calls the PersonBasic API
    class PersonBasic < Api
      attr_accessor :nric_fin, :attributes, :txn_no

      def initialize(nric_fin:, txn_no: nil, attributes: nil)
        raise UnavailableError, 'person-basic endpoint is not available for public-facing APIs.' if config.public?

        @attributes = Attributes.parse(attributes)
        @nric_fin = nric_fin
        @txn_no = txn_no
      end

      def call
        super do
          headers = header(params: params)
          endpoint_url = "/#{slug}?#{params.to_query}"

          response = http.request_get(endpoint_url, headers)
          parse_response(response)
        end
      end

      def slug
        "gov/v3/person-basic/#{nric_fin}/"
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

      def errors
        %w[401 403 404 428 default]
      end

      def parse_response(response)
        super do
          json = decrypt_jwe(response.body)
          json = decode_jws(json.delete('\"')) unless config.sandbox?

          Response.new(success: true, data: json)
        end
      end
    end
  end
end
