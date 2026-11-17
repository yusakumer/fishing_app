require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  describe "GET /api/v1/users/me" do
    context "未ログインの場合" do
      it "401を返す" do
        get "/api/v1/users/me", as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "ログイン済みの場合" do
      let(:user) { FactoryBot.create(:user) }

      it "本人のプロフィールを200で返す" do
        post "/users/sign_in",
             params: { user: { email: user.email, password: user.password } },
             as: :json
        expect(response).to have_http_status(:ok)

        get "/api/v1/users/me", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(
          "user" => {
            "id" => user.id,
            "email" => user.email,
            "name" => user.name,
            "prefecture_id" => user.prefecture_id
          }
        )
      end
    end
  end
end
