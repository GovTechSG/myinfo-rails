class ApplicationController < ActionController::Base
  def index
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

  def callback
    # MyInfo on test environments only whitelists localhost:3001/callback
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
