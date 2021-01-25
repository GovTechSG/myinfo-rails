class ApplicationController < ActionController::Base
  def index
    # Step 1: Redirect to authorise
    redirect_to MyInfo::V3::AuthoriseUrl.call(
      nric_fin: 'S9812381D',
      redirect_uri: callback_url,
      purpose: 'testing',
      state: SecureRandom.hex
    )
  end

  def callback
    # MyInfo on test environments only whitelists localhost:3001/callback
    response = MyInfo::V3::Token.call(
      code: params[:code],
      state: params[:state],
      redirect_uri: callback_url
    )

    if response.success?
      response = MyInfo::V3::Person.call(access_token: response.data)
    end

    render plain: response.data
  end

  private

  def callback_url
    url_for(action: 'callback', only_path: false)
  end
end
