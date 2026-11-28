require 'rails_helper'
require 'time'

RSpec.describe "Users::Sessions", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /api/v1/users/sign_in" do
    let(:user) { FactoryBot.create(:user) }

    context "パスワードが間違っている場合" do
      it "401を返し、認証Cookieを発行しない" do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: "incorrect-password" } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(cookies["access_token"]).to be_blank

        # ログイン失敗後も、認証が必要なAPIは利用できない
        get "/api/v1/users/me", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "メールアドレスが未登録の場合" do
      it "401を返し、認証Cookieを発行しない" do
        unregistered_email = "unregistered@example.com"
        expect(User.exists?(email: unregistered_email)).to be(false)

        # 登録済みユーザーの正しいパスワードを使い、メールだけを変える
        post "/api/v1/users/sign_in",
             params: { user: { email: unregistered_email, password: user.password } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(cookies["access_token"]).to be_blank

        get "/api/v1/users/me", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it "ログイン時にCookieの有効期限を1日後に設定する" do
      freeze_time do
        post "/api/v1/users/sign_in",
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

  describe "DELETE /api/v1/users/sign_out" do
    let(:user) {FactoryBot.create(:user)}
    it "ログアウト後は同じJWTで認証できない" do
      post "/api/v1/users/sign_in",
          params: { user: { email: user.email, password: user.password } },
          as: :json

      expect(response).to have_http_status(:ok)

      token_before_logout = cookies["access_token"]
      expect(token_before_logout).to be_present

      get "/dev/auth_checks", as: :json
      expect(response).to have_http_status(:ok)

      delete "/api/v1/users/sign_out",as: :json
      expect(response).to have_http_status(:no_content)
      expect(cookies["access_token"]).to be_blank

      cookies["access_token"] = token_before_logout
      get "/dev/auth_checks", as: :json
      expect(response).to have_http_status(:unauthorized)

    end

  end
end
