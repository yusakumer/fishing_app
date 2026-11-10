# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # Deviseの登録後ログイン処理を上書きし、ログイン情報をセッションには保存しない。
  def sign_up(resource_name, resource)
    sign_in(resource_name,resource, store: false)
    token = request.env.fetch("warden-jwt_auth.token")
    cookies[:access_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      path: "/"
    }
  end

  # Deviseが登録処理の結果を返す際に呼ぶメソッドを上書きする。
  # 保存済みなら201と完了メッセージ、未保存なら422とエラー一覧をJSONで返す。
  # ここではUserの保存は行わない。現在の応答は登録用なので、更新機能の実装時は見直す。
  def respond_with(resource,_opts = {})
    if resource.persisted?
      render status: :created, json: { message: "登録が完了しました。" }
    else
      render status: :unprocessable_content, json: { message: resource.errors.full_messages }
    end

  end

  # If you have extra params to permit, append them to the sanitizer.
  # create前のbefore_actionから呼ばれ、登録時に受け付ける項目へ名前と都道府県IDを追加する。
  # 入力の許可だけを行い、値の検証やDB保存は別の処理に任せる。
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :prefecture_id])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end


end
