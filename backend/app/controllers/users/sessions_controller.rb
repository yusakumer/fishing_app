# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
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

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
