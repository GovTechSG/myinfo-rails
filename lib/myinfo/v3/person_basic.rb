# frozen_string_literal: true

module MyInfo
  module V3
    # Calls the PersonBasic API
    class PersonBasic < Api
      attr_accessor :nric_fin, :attributes, :txn_no

      def initialize(nric_fin:, txn_no: nil, attributes: Api::DEFAULT_ATTRIBUTES)
        @attributes = attributes
        @nric_fin = nric_fin
        @txn_no = txn_no
      end

      def call
        headers = header(params: params)
        endpoint_url = "/#{slug}?#{params.to_query}"

        response = http.request_get(endpoint_url, headers)
        parse_response(response)
      end

      def support_gzip?
        true
      end

      def slug
        "gov/v3/person-basic/#{nric_fin}/"
      end

      def nonce
        SecureRandom.hex
      end

      def params
        {
          sp_esvcId: config.singpass_eservice_id,
          nonce: nonce,
          txnNo: txn_no,
          attributes: attributes.join(','),
          client_id: config.client_id
        }.compact
      end

      def errors
        %w[401 403 404 428 default]
      end

      def parse_response(response)
        super do
          jws = decrypt_jwe(response.body.to_s)
          result = format_response(jws)

          Response.new(success: true, data: result)
        end
      end

      def format_response(jws)
        if config.sandbox?
          jws
        else
          decode_jws(jws.delete('\"'))
        end
      end
    end
  end
end
