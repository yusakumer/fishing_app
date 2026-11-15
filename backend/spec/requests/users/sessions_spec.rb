require 'rails_helper'
require 'time'

RSpec.describe "Users::Sessions", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /users/sign_in" do
    let(:user) { FactoryBot.create(:user) }

    it "ログイン時にCookieの有効期限を1日後に設定する" do
      freeze_time do
        post "/users/sign_in",
             params: { user: { email: user.email, password: user.password } },
             as: :json
        expect(response).to have_http_status(:ok)

        # 次のリクエストを送る前に、Cookieの期限をレスポンスから取り出す。
        cookie_headers = Array(response.headers["Set-Cookie"])
        access_token_cookie = cookie_headers.find do |header|
          header.start_with?("access_token=")
        end
        expect(access_token_cookie).to be_present

        expires_text = access_token_cookie[/expires=([^;]+)/i, 1]
        expect(expires_text).to be_present

        # HTTPの日付文字列を時刻へ変換し、1日後と一致するか確認する。
        expect(Time.httpdate(expires_text)).to eq(1.day.from_now)
      end
    end
  end

  describe "DELETE /users/sign_out" do
    let(:user) {FactoryBot.create(:user)}
    it "ログアウト後は同じJWTで認証できない" do
      post "/users/sign_in",
          params: { user: { email: user.email, password: user.password } },
          as: :json

      expect(response).to have_http_status(:ok)

      token_before_logout = cookies["access_token"]
      expect(token_before_logout).to be_present

      get "/dev/auth_checks", as: :json
      expect(response).to have_http_status(:ok)

      delete "/users/sign_out",as: :json
      expect(response).to have_http_status(:no_content)

      cookies["access_token"] = token_before_logout
      get "/dev/auth_checks", as: :json
      expect(response).to have_http_status(:unauthorized)

    end

  end
end
