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
        post "/api/v1/users/sign_in",
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

  describe "PATCH /api/v1/users/me" do
    context "未ログインの場合" do
      let!(:user) { FactoryBot.create(:user) }

      it "401を返し、ユーザー情報を更新しない" do
        expect {
          patch "/api/v1/users/me",
                params: { user: { name: "更新用の名前" } },
                as: :json
        }.not_to change { user.reload.attributes }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "ログイン済みで入力が不正な場合" do
      let(:user) { FactoryBot.create(:user) }

      before do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: user.password } },
             as: :json
        expect(response).to have_http_status(:ok)
      end

      it "名前が空なら422を返し、ユーザー情報を更新しない" do
        expect {
          patch "/api/v1/users/me",
                params: { user: { name: "" } },
                as: :json
        }.not_to change { user.reload.attributes }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end

      it "都道府県が空なら422を返し、名前も含めて更新しない" do
        expect {
          patch "/api/v1/users/me",
                params: { user: { name: "更新用の名前", prefecture_id: nil } },
                as: :json
        }.not_to change { user.reload.attributes }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end
    end

    context "ログイン済みで正しい入力の場合" do
      let(:user) { FactoryBot.create(:user) }
      let(:another_prefecture) { FactoryBot.create(:prefecture) }

      # 更新用のダミーデータ
      let(:update_params) do
        {
          name: "更新用の名前",
          prefecture_id: another_prefecture.id
        }
      end

      it "更新されたUser情報と200を返す" do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: user.password } },
             as: :json
        expect(response).to have_http_status(:ok)

        patch "/api/v1/users/me",
              params: { user: update_params },
              as: :json
        expect(response).to have_http_status(:ok)

        # DBから読み直し、名前と都道府県が保存されたことを確認する
        user.reload
        expect(user.name).to eq(update_params[:name])
        expect(user.prefecture_id).to eq(another_prefecture.id)

        expect(response.parsed_body["user"]).to eq(
          "id" => user.id,
          "email" => user.email,
          "name" => update_params[:name],
          "prefecture_id" => another_prefecture.id
        )
      end
    end
  end
end
