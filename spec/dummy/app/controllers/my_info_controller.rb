class MyInfoController < ApplicationController
  def index
    callback = url_for(action: 'callback', controller: '/my_info', only_path: false)

    redirect_to MyInfo::V3::AuthoriseUrl.call(
      nric_fin: 'S9812381D',
      redirect_uri: callback,
      purpose: 'test',
      state: SecureRandom.hex
    )
  end

  def callback
  end
end
