# frozen_string_literal: true

# rubocop:disable all
module MyInfo
  module V3
    module Response
      class PersonBasic
        attr_accessor :json, :my_info_json, :cleared_json, :incomplete

        FIELDS_NOT_TO_CLEAR = %i[email contact_number contact_country_code].freeze

        # rubocop:disable Metrics/AbcSize
        def initialize(my_info_json)
          @my_info_json = my_info_json
          @json = {
            name: '', residential_status: '', dob: '', race: '', gender: '',
            residential_address: {}
          }
          @incomplete = false
          @cleared_json = {
            name: nil, residential_status: nil, dob: nil, race: nil, gender: nil,
            residential_address: {}
          }

          build_json
        end

        private

        # build json by using json_key_map as base structure, and fill value from my_info_json API response
        def build_json
          json_key_map.each_pair do |key, value|
            my_info_value = actual_value(value)
            set_incomplete(key, value)
            # Don't set email/contact json key if nil or blank
            @json[key] = my_info_value if my_info_value.present?
          end

          merge_address_details
        end

        def set_incomplete(key, value)
          @incomplete = true if value.blank? && FIELDS_NOT_TO_CLEAR.exclude?(key)
        end

        # fetch actual value from my_info_json
        def actual_value(attribute, my_info_json = @my_info_json) # rubocop:disable Metrics/AbcSize
          if attribute.instance_of?(String)
            my_info_json[attribute].try(:[], 'value') || my_info_json[attribute].try(:[], 'code')
          elsif attribute.instance_of?(Array)
            if attribute[1].instance_of?(String)
              my_info_json[attribute[0]].try(:[], attribute[1]).try(:[], 'value')
            else
              # attribute[1] is an array ['code', 'nbr'], need both values to find country code
              parse_country(
                my_info_json[attribute[0]].try(:[], attribute[1][0]).try(:[], 'value'),
                my_info_json[attribute[0]].try(:[], attribute[1][1]).try(:[], 'value')
              )
            end
          end
        end

        # parse country from dialing code and phone number using Phonelib
        def parse_country(dialing_code, phone_number)
          Phonelib.parse("#{dialing_code}#{phone_number}").try(:country)
        end

        # map MGP to MyInfo fields
        def json_key_map
          {
            name: 'name',
            residential_status: 'residentialstatus',
            dob: 'dob',
            race: 'race',
            gender: 'sex',
            contact_number: %w[mobileno nbr],
            email: 'email',
            contact_country_code: ['mobileno', %w[areacode nbr]]
          }
        end

        def merge_address_details
          country_code = @my_info_json['regadd'].try(:[], 'country').try(:[], 'code') || ''
          @json[:residential_address][:country_code] = country_code

          if country_code == 'SG'
            @cleared_json[:residential_address][:country_code] = nil
            merge_local_address
          else
            merge_overseas_address
            @incomplete = true if country_code.blank?
          end
        end

        def merge_overseas_address
          line1 = @my_info_json['regadd'].try(:[], 'line1').try(:[], 'value') || ''
          line2 = @my_info_json['regadd'].try(:[], 'line2').try(:[], 'value') || ''

          # check data completeness
          @incomplete = true if line1.blank? || line2.blank?

          # fill in data from MyInfo
          @json[:residential_address][:overseas_line_1] = line1
          @json[:residential_address][:overseas_line_2] = line2

          # disable address details & clear them when clear MyInfo
          @cleared_json[:residential_address][:overseas_line_1] = nil
          @cleared_json[:residential_address][:overseas_line_2] = nil
        end

        def merge_local_address
          block = @my_info_json['regadd'].try(:[], 'block').try(:[], 'value') || ''
          unit =  @my_info_json['regadd'].try(:[], 'unit').try(:[], 'value') || ''
          level = @my_info_json['regadd'].try(:[], 'floor').try(:[], 'value') || ''
          street = @my_info_json['regadd'].try(:[], 'street').try(:[], 'value') || ''
          building_name = @my_info_json['regadd'].try(:[], 'building').try(:[], 'value') || ''
          postal = @my_info_json['regadd'].try(:[], 'postal').try(:[], 'value') || ''

          # check data completeness
          @incomplete = true if block.blank? || street.blank? || postal.blank?

          # fill in data from MyInfo
          @json[:residential_address][:block] = block
          @json[:residential_address][:unit] = unit
          @json[:residential_address][:level] = level
          @json[:residential_address][:street] = street
          @json[:residential_address][:building_name] = building_name
          @json[:residential_address][:postal] = postal

          # to disable address details & clear them when clear MyInfo
          @cleared_json[:residential_address][:block] = nil
          @cleared_json[:residential_address][:unit] = nil
          @cleared_json[:residential_address][:level] = nil
          @cleared_json[:residential_address][:street] = nil
          @cleared_json[:residential_address][:building_name] = nil
          @cleared_json[:residential_address][:postal] = nil
        end
        # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      end
    end
  end
end
# rubocop:enable all
