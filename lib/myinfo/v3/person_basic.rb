# frozen_string_literal: true

module MyInfo
  module V3
    # Calls the PersonBasic API
    class PersonBasic < Api
      DEFAULT_ATTRIBUTES = %i[name sex race dob residentialstatus email mobileno regadd].freeze
      attr_accessor :nric_fin, :attributes

      def initialize(nric_fin:, attributes: nil)
        @attributes = attributes || DEFAULT_ATTRIBUTES
        @nric_fin = nric_fin
      end

      def call
        headers = header(params: params)
        endpoint_url = "/#{slug}/#{nric_fin}?#{params.to_query}"

        response = http.request_get(endpoint_url, headers)
        parse_response(response)
      rescue StandardError => e
        { success: false, data: e.message.to_s }
      end

      def slug
        'gov/v3/person-basic'
      end

      def gzip_support?
        true
      end

      def nonce
        SecureRandom.hex
      end

      def txn_no
        Time.now.to_i
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

      def parse_response(response)
        if response.code == 200
          jws = decrypt_jwe(response.body.to_s)
          result = format_response(jws)

          { success: true,
            data: result.json,
            myinfo_incomplete: result.myinfo_incomplete,
            cleared_json: result.cleared_json }
        else
          { success: false, data: "#{response.code} - #{response.body}" }
        end
      end

      def format_response(jws)
        decoded = if config.sandbox?
                    jws
                  else
                    decode_jws(jws.delete('\"')).first
                  end

        Response::PersonBasic.new(decoded)
      end
    end
  end
end
