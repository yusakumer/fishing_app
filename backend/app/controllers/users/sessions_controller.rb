# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  prepend_before_action only: :destroy do
    authenticate_user!(force: true)
  end
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end
  #
  # POST /resource/sign_in
  # def create
  #   super
  # end
  #
  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # Deviseのログイン成功時の応答を上書きする。
  # Gemが発行したJWTをHttpOnly Cookieへ設定し、200と成功メッセージをJSONで返す。
  # JWTそのものの発行やメール・パスワードの照合は、このメソッドでは行わない。
  def respond_with(resource, _opts = {})
    token = request.env.fetch("warden-jwt_auth.token")
    cookies[:access_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      path: "/"
    }
    render status: :ok, json: {message: "ログインに成功しました"}
  end

  private

  # Deviseがログアウト時（すでにログアウト状態の場合も含む）に呼ぶ応答処理を上書きする。
  # 保存時と同じパスのCookieを削除するよう指示し、渡されたステータスを本文なしで返す。
  # JWTのDenylistへの登録はdevise-jwt側に任せる。Cookie削除だけではJWT自体は失効しない。
  def respond_to_on_destroy(non_navigational_status: :no_content)
    cookies.delete(:access_token,path:"/")
    head non_navigational_status
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
