require 'rails_helper'

RSpec.describe "Dev::AuthChecks", type: :request do
  describe "GET /dev/auth_checks" do
    context "Cookieがない場合" do
      it "401を返す" do
        get "/dev/auth_checks", as: :json
        expect(response).to have_http_status(:unauthorized)
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
      let(:user) { FactoryBot.create(:user) }
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
