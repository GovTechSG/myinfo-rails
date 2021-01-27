# Rails wrapper for MyInfo API

![tests](https://github.com/GovTechSG/myinfo/workflows/tests/badge.svg?branch=main)


MyInfo documentation (Public): https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.1.0.html
MyInfo documentation (Government): https://public.cloud.myinfo.gov.sg/myinfo/tuo/myinfo-tuo-specs.html

## Trying out
1. Use ruby 2.7
2. `bundle install`
3. `cd spec/dummy && rails s`
4. Navigate to `localhost:3001`

## Basic Setup (Public)

1. `bundle add myinfo`
2. Create a `config/initializers/myinfo.rb` and add the required configuration based on your environment.
```ruby
  MyInfo.configure do |config|
    config.app_id = ''
    config.client_id = ''
    config.client_secret = ''
    config.base_url = 'test.api.myinfo.gov.sg' # don't set https://
    config.redirect_uri = 'https://localhost:3001/callback'
    config.public_facing = true
    config.private_key = File.read(Rails.root.join('private_key_location'))
    config.public_cert = File.read(Rails.root.join('public_cert_location'))
    config.sandbox = false # optional, false by default
    config.proxy = { address: 'proxy_address', port: 'proxy_port' } # optional, nil by default
  end
```

3. To obtain a person's MyInfo information, we need to authorise the query first:
```ruby
redirect_to MyInfo::V3::AuthoriseUrl.call(
      purpose: 'set your purpose here',
      state: SecureRandom.hex # set a state to check on callback
    )
```

4. On `redirect_url`, obtain a `MyInfo::V3::Token`. This token can only be used once.
```ruby
    response = MyInfo::V3::Token.call(
      code: params[:code],
      state: params[:state]
    )
```

5. Obtain the `access_token` from the `response` and query for `MyInfo::V3::Person`:
```ruby
result = MyInfo::V3::Person.call(access_token: response.data) if response.success?
```

## Basic Setup (Government)

1. `bundle add myinfo`
2. Create a `config/initializers/myinfo.rb` and add the required configuration based on your environment.
```ruby
  MyInfo.configure do |config|
    config.app_id = ''
    config.client_id = ''
    config.client_secret = ''
    config.base_url = 'test.api.myinfo.gov.sg' # don't set https://
    config.redirect_uri = 'https://localhost:3001/callback'
    config.singpass_eservice_id = 'MYINFO-CONSENTPLATFORM'
    config.private_key = File.read(Rails.root.join('private_key_location'))
    config.public_cert = File.read(Rails.root.join('public_cert_location'))
    config.sandbox = false # optional, false by default
    config.proxy = { address: 'proxy_address', port: 'proxy_port' } # optional, nil by default
  end
```

3. To obtain a person's MyInfo information, we need to authorise the query first:
```ruby
redirect_to MyInfo::V3::AuthoriseUrl.call(
      nric_fin: "user's NRIC", # see documentation for list of sample NRICs
      purpose: 'set your purpose here',
      state: SecureRandom.hex # set a state to check on callback
    )
```

4. On `redirect_url`, obtain a `MyInfo::V3::Token`. This token can only be used once.
```ruby
    response = MyInfo::V3::Token.call(
      code: params[:code],
      state: params[:state]
    )
```

5. Obtain the `access_token` from the `response` and query for `MyInfo::V3::Person`:
```ruby
result = MyInfo::V3::Person.call(access_token: response.data) if response.success?
```

## Advanced
- `attributes` can be passed to `AuthoriseUrl` and `Person` as an array to override the default attributes queried - check MyInfo for a list of available attributes.

- `success?` can be called on `MyInfo::V3::Response` to determine whether the query has succeeded or failed. Check MyInfo API for a list of responses and how to deal with them.

## Disclaimer
Provided certificates, keys and secrets for the dummy application and tests are either obtained from [MyInfo Demo App](https://github.com/ndi-trusted-data/myinfo-demo-app) or free samples online, and are for demonstration purposes only. They should not be re-used for staging or production environments.