if Rails.env.development?
  MyInfo.configure do |config|
    config.app_id = 'STG2-MYINFO-SELF-TEST'
    config.client_id = 'STG2-MYINFO-SELF-TEST'
    config.base_url = 'https://test.api.myinfo.gov.sg'
    config.singpass_eservice_id = 'MYINFO-CONSENTPLATFORM'
  end
end