if Rails.env.development?
  # Credentials obtained from https://github.com/ndi-trusted-data/myinfo-demo-app
  MyInfo.configure do |config|
    config.app_id = 'STG2-MYINFO-SELF-TEST'
    config.client_id = 'STG2-MYINFO-SELF-TEST'
    config.public_facing = true
    config.singpass_eservice_id = 'MYINFO-CONSENTPLATFORM'
    config.client_secret = '44d953c796cccebcec9bdc826852857ab412fbe2'
    config.redirect_uri = 'http://localhost:3001/callback'
    config.base_url = 'test.api.myinfo.gov.sg'
    config.private_key = File.read(Rails.root.join('config/certs/stg-demoapp-client-privatekey-2018.pem'))
    config.public_cert = File.read(Rails.root.join('config/certs/staging_myinfo_public_cert.cer'))
    # config.gateway_url = 'https://test_gateway_url' # optional - dummy value given here
    # config.gateway_key = '44d953c796cccebcec9bdc826852857ab412fbe2' # optional - dummy value given
    # MyInfo V4 stuffs
    config.private_encryption_key = File.read(Rails.root.join('config/certs/sample-encryption-private-key.pem'))
    config.private_signing_key = File.read(Rails.root.join('config/certs/sample-signing-private-key.pem'))
    config.authorise_jwks_base_url = "test.authorise.singpass.gov.sg"
  end
end