if Rails.env.development?
  # Credentials obtained from https://github.com/ndi-trusted-data/myinfo-demo-app
  MyInfo.configure do |config|
    config.app_id = 'STG2-MYINFO-SELF-TEST'
    config.client_id = 'STG2-MYINFO-SELF-TEST'
    config.client_secret = '44d953c796cccebcec9bdc826852857ab412fbe2'
    config.base_url = 'test.api.myinfo.gov.sg'
    config.singpass_eservice_id = 'MYINFO-CONSENTPLATFORM'
    config.private_key = File.read(Rails.root.join('config/certs/stg-demoapp-client-privatekey-2018.pem'))
    config.public_cert = File.read(Rails.root.join('config/certs/staging_myinfo_public_cert.cer'))
  end
end