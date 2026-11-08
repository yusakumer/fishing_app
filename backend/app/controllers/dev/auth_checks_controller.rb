class Dev::AuthChecksController < ApplicationController
  before_action :authenticate_user!
  # before_actionで認証を通過した場合だけ、200と本人のIDを返す確認用アクション。
  # Cookie経由で意図したユーザーとして認証できるか、PostmanやRSpecで確かめるために使う。
  def show
    render status: :ok, json: { message:"認証できました。", user_id: current_user.id }
  end
end
