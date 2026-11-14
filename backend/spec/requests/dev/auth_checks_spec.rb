require 'rails_helper'

RSpec.describe "Dev::AuthChecks", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "GET /dev/auth_checks" do
    let(:user) { FactoryBot.create(:user) }


    context "Cookieがない場合" do
      it "401を返す" do
        get "/dev/auth_checks", as: :json
        expect(response).to have_http_status(:unauthorized)
      end

    end

    context "JWTの有効期限が切れている場合" do
      it "401を返す" do
        post "/users/sign_in",
             params: { user: {email: user.email, password: user.password } },
             as: :json

        expect(response).to have_http_status(:ok)

        token = cookies["access_token"]

        expect(token).to be_present

        #同じJWTが、期限内になら使用可能の確認
        get "/dev/auth_checks", as: :json
        expect(response).to have_http_status(:ok)

        #JWTがの有効期限（1日）、1日と1秒後に進め、JWTが失効処理される確認
        travel_to(1.day.from_now + 1.minute) do
          get "/dev/auth_checks",
              headers: { "Authorization": "Bearer #{token}" },
              as: :json

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "CookieのJWTが不正な場合" do
      it "401を返す" do
        cookies["access_token"] = "invalid_token"

        get "/dev/auth_checks", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "正常なCookieの場合" do

      it "200とログインしたユーザーIDを返す" do
        post "/users/sign_in",
             params: {
               user: {
                 email: user.email,
                 password: user.password,
               }
             },
             as: :json

        expect(response).to have_http_status(:ok)
        expect(cookies["access_token"]).to be_present

        get "/dev/auth_checks",as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["user_id"]).to eq(user.id)
      end
    end
  end
end
