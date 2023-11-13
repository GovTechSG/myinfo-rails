class ApplicationController < ActionController::Base
  def index
    myinfo_v4_index
  end

  def callback
    myinfo_v4_callback
  end

  private

  def myinfo_v4_index
    # Step 1: Redirect to authorise
    code_verifier, code_challenge = MyInfo::V4::Session.call

    session[:code_verifier] = code_verifier
    redirect_to MyInfo::V4::AuthoriseUrl.call(
      purpose: 'demonstration', code_challenge: code_challenge, nric_fin: 'S9812381D', attributes: 'uinfin name sex race'
    )
  end

  def myinfo_v4_callback
    key_pairs = SecurityHelper.generate_session_key_pair
    response = MyInfo::V4::Token.call(
      key_pairs: key_pairs,
      auth_code: params[:code],
      code_verifier: session[:code_verifier]
    )

    if response.success?
      response = MyInfo::V4::Person.call(key_pairs: key_pairs,
                                         access_token: response.data,
                                         attributes: %i[uinfin name sex race])
    end

    render plain: response.data
  end

  def myinfo_v3_index
    # Step 1: Redirect to authorise
    redirect_to MyInfo::V3::AuthoriseUrl.call(
      nric_fin: 'S9812381D',
      purpose: 'testing',
      state: SecureRandom.hex
    )

    # Try PersonBasic if you want
    # response = MyInfo::V3::PersonBasic.call(
    #   nric_fin: 'S9812381D',
    #   txn_no: '1'
    # )
    # render plain: response.data
  end

  def myinfo_v3_callback
    response = MyInfo::V3::Token.call(
      code: params[:code],
      state: params[:state],
      )

    if response.success?
      response = MyInfo::V3::Person.call(access_token: response.data)
    end

    render plain: response.data
  end
end
